import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:clavis/src/pages/downloads/util.dart';
import 'package:clavis/src/util/logger.dart';
import 'package:dio/dio.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:path/path.dart';

enum DownloadStatus {
  finished,
  running,
  pending,
  downloadReturnedError,
  cancelled,
  unknown,
}

class Progress {

  static const _dlSpeedBufferSize = 500; 

  Progress({
    required this.speeds,
    required this.bytesLoaded,
    required this.bytesTotal,
    required this.cancelToken,
  });
  Progress.initial()
    : speeds = [],
      bytesLoaded = 0,
      bytesTotal = 0,
      cancelToken = CancelToken();
  List<(double, DateTime)> speeds;
  int bytesLoaded;
  int bytesTotal;
  CancelToken cancelToken;
  updateWith({
    int? bytesLoaded,
    int? bytesTotal,
    double? speed,
    CancelToken? cancelToken,
  }) {
    if (speed != null) {
      if (speeds.length >= _dlSpeedBufferSize) {
        speeds = speeds.sublist(1) + [(speed, DateTime.now())];
      } else {
        speeds += [(speed, DateTime.now())];
      }
    }
    this.bytesLoaded = bytesLoaded ?? this.bytesLoaded;
    this.bytesTotal = bytesTotal ?? this.bytesTotal;
    this.cancelToken = cancelToken ?? this.cancelToken;
  }
}

class DownloadOp {
  GamevaultGame game;
  ApiClient api;
  String downloadPath;
  Progress progress;
  DownloadStatus status;
  DownloadOp.initial({
    required this.game,
    required this.api,
    required this.downloadPath,
  }) : progress = Progress.initial(),
       status = DownloadStatus.pending;
}

typedef DownloadOps = List<DownloadOp>;

class DownloadContext {
  DownloadContext({
    this.activeOp,
    this.pendingOps = const [],
    this.closedOps = const [],
  });
  DownloadOp? activeOp;
  DownloadOps pendingOps;
  DownloadOps closedOps;
  DownloadContext copyWith({
    DownloadOp? activeOp,
    DownloadOps? pendingOps,
    DownloadOps? closedOps,
  }) {
    return DownloadContext(pendingOps: pendingOps ?? this.pendingOps);
  }

  bool get hasActive => activeOp != null;
  bool get hasPending => pendingOps.isNotEmpty;
  bool get hasClosed => closedOps.isNotEmpty;
}

class DownloadsRepository {
  DownloadContext _downloads = DownloadContext();
  final _downloadsStream = StreamController<DownloadContext>.broadcast();
  final _activeDlHist = Queue<(int, DateTime)>();
  int _activeDlBytes = 0;
  static const _averagingWindow = 1000;

  DownloadsRepository() {
    Future(() async {
      await for (final download in _downloadsStream.stream) {
        if (!_downloads.hasActive) {
          _activeDlBytes = 0;
          _activeDlHist.clear();
        }
        _downloads = download;
      }
    }).onError((error, stackTrace) {
      log.e(
        "download queue setter errored out",
        error: error,
        stackTrace: stackTrace,
      );
    });

    Timer.periodic(Duration(milliseconds: 50), _emitDlHist);
  }

  Stream<DownloadContext> get downloads async* {
    yield _downloads;
    yield* _downloadsStream.stream;
  }

  Future<void> queueDownload(
    ApiClient api,
    String targetDir,
    GamevaultGame game,
  ) async {
    final filePath = game.filePath;
    final op = DownloadOp.initial(
      game: game,
      api: api,
      downloadPath: join(
        targetDir,
        basename(filePath ?? "game-${game.id}.unknown"),
      ),
    );
    _downloads.pendingOps = _downloads.pendingOps + [op];
    _downloadsStream.add(_downloads.copyWith());

    await _startNextInQueue();
  }

  Future<void> queueClosed(num gameId) async {
    final idx = _downloads.closedOps.indexWhere((op) => op.game.id == gameId);
    if (idx == -1) return;

    final op = _downloads.closedOps.removeAt(idx);
    op.status = DownloadStatus.pending;
    op.progress = Progress.initial();
    await queueDownload(op.api, op.downloadPath, op.game);
  }

  void removeFromPending(num gameId) {
    final idx = _downloads.pendingOps.indexWhere((op) => op.game.id == gameId);
    if (idx == -1) return; // nothing to remove

    final op = _downloads.pendingOps.removeAt(idx);
    op.progress.cancelToken.cancel();
    _downloadsStream.add(_downloads);
  }

  void removeFromClosed(num gameId) {
    _downloads.closedOps.removeWhere((op) => op.game.id == gameId);
    _downloadsStream.add(_downloads);
  }

  void stopActiveOp() {
    if (!_downloads.hasActive) return;
    _closeActiveOp(DownloadStatus.cancelled);
  }

  Future<void> activateOp(num gameId) async {
    final idx = _downloads.pendingOps.indexWhere((op) => op.game.id == gameId);
    if (idx <= 0) return; // nothing to push

    // stop first
    _closeActiveOp(DownloadStatus.cancelled);
    _downloads.activeOp = _downloads.pendingOps.removeAt(idx);
    await _startNextInQueue();
  }

  Future<void> _startNextInQueue() async {
    if (_downloads.hasActive) return; // active op not yet finished

    _downloads.activeOp = _downloads.pendingOps.removeAt(0);
    await _startActiveOp();
  }

  Future<void> _startActiveOp() async {
    if (!_downloads.hasActive) return;
    final activeOp = _downloads.activeOp!;
    final gameId = activeOp.game.id;
    final cancelToken = CancelToken();
    void onProgress(int count, total) {
      if (gameId != _downloads.activeOp?.game.id) {
        // something else has started in between
        cancelToken.cancel();
        return;
      }

      if (_activeDlHist.length >= _averagingWindow) _activeDlHist.removeFirst();
      _activeDlHist.addLast((count, DateTime.now()));
      _activeDlBytes = count;

      // if (!_updateActiveOp(bytesLoaded: count, bytesTotal: total)) {
      //   // download not in queue for some reason, nothing we can do ...
      //   cancelToken.cancel();
      // }
    }

    final downloadTask = _prepareDownload(
      activeOp.api,
      activeOp.downloadPath,
      activeOp.game.id,
      cancelToken,
      onProgress,
    );
    _updateActiveOp(status: DownloadStatus.running, cancelToken: cancelToken);

    final response = await downloadTask;
    if (response.statusCode != 200) {
      _closeActiveOp(DownloadStatus.downloadReturnedError);
    } else {
      _closeActiveOp(DownloadStatus.finished);
    }

    await _startNextInQueue();
  }

  Future<Response> _prepareDownload(
    ApiClient api,
    String targetPath,
    num gameId,
    CancelToken token,
    void Function(int count, int total) onProgress,
  ) async {
    await _makeDirIfNotExists(targetPath);
    final uri = "${api.basePath}/api/games/$gameId/download";
    Map<String, String> headers = {};
    await api.authentication!.applyToParams([], headers);

    return Dio().download(
      uri,
      targetPath,
      onReceiveProgress: onProgress,
      cancelToken: token,
      options: Options(headers: headers),
    );
  }

  bool _updateActiveOp({
    DownloadStatus? status,
    int? bytesLoaded,
    double? speed,
    int? bytesTotal,
    CancelToken? cancelToken,
  }) {
    if (!_downloads.hasActive) return false;

    _downloads.activeOp!.progress.updateWith(
      bytesLoaded: bytesLoaded,
      bytesTotal: bytesTotal,
      cancelToken: cancelToken,
      speed: speed,
    );
    if (status != null) _downloads.activeOp!.status = status;

    _downloadsStream.add(_downloads);
    return true;
  }

  void _closeActiveOp(DownloadStatus status) {
    if (!_downloads.hasActive) return;
    _downloads.activeOp!.progress.cancelToken.cancel();

    _downloads.closedOps = [_downloads.activeOp!] + _downloads.closedOps;
    _downloads.activeOp = null;
  }

  Future<void> _makeDirIfNotExists(String target) async {
    final d = File(target).parent;
    if (await d.exists()) return;
    await d.create(recursive: true);
  }

  void _emitDlHist(Timer t) {
    if (!_downloads.hasActive) return;
    if (_activeDlHist.isEmpty) return;

    final speeds = downloadSpeeds(_activeDlHist.toList());
    final avg =
        speeds.reduce((a, b) => a + b) /
        (speeds.isNotEmpty ? speeds.length : 1);
    _updateActiveOp(bytesLoaded: _activeDlBytes, speed: avg);
  }
}
