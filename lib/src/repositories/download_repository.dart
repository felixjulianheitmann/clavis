import 'dart:async';
import 'dart:io';

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
  Progress({
    required this.bytesLoaded,
    required this.bytesTotal,
    required this.cancelToken,
  });
  Progress.initial()
    : bytesLoaded = 0,
      bytesTotal = 0,
      cancelToken = CancelToken();
  int bytesLoaded;
  int bytesTotal;
  CancelToken cancelToken;
  updateWith({int? bytesLoaded, int? bytesTotal, CancelToken? cancelToken}) {
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

  DownloadsRepository() {
    Future(() async {
      await for (final download in _downloadsStream.stream) {
        _downloads = download;
      }
    }).onError((error, stackTrace) {
      log.e(
        "download queue setter errored out",
        error: error,
        stackTrace: stackTrace,
      );
    });
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
    final op = DownloadOp.initial(
      game: game,
      api: api,
      downloadPath: join(targetDir, basename(game.filePath)),
    );
    _downloads.pendingOps.add(op);
    _downloadsStream.add(_downloads.copyWith());

    await _startNextInQueue();
  }

  void removeFromQueue(num gameId) {
    final idx = _downloads.pendingOps.indexWhere((op) => op.game.id == gameId);
    if (idx == -1) return; // nothing to remove

    final op = _downloads.pendingOps.removeAt(idx);
    op.progress.cancelToken.cancel();
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
    final cancelToken = CancelToken();
    void onProgress(int count, total) {
      if (!_updateActiveOp(bytesLoaded: count, bytesTotal: total)) {
        // download not in queue for some reason, nothing we can do ...
        cancelToken.cancel();
      }
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
    int? bytesTotal,
    CancelToken? cancelToken,
  }) {
    if (!_downloads.hasActive) return false;

    _downloads.activeOp!.progress.updateWith(
      bytesLoaded: bytesLoaded,
      bytesTotal: bytesTotal,
      cancelToken: cancelToken,
    );
    if (status != null) _downloads.activeOp!.status = status;

    _downloadsStream.add(_downloads);
    return true;
  }

  void _closeActiveOp(DownloadStatus status) {
    if (!_downloads.hasActive) return;
    _downloads.activeOp!.progress.cancelToken.cancel();

    _downloads.closedOps.insert(0, _downloads.activeOp!);
    _downloads.activeOp = null;
  }

  Future<void> _makeDirIfNotExists(String target) async {
    final d = File(target).parent;
    if (await d.exists()) return;
    await d.create(recursive: true);
  }
}
