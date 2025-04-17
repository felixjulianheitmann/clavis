

import 'dart:async';

import 'package:clavis/src/util/logger.dart';
import 'package:gamevault_client_sdk/api.dart';

class DownloadOp {
  DownloadOp({required this.gameId});
  num gameId;
}

class DownloadOps {
  DownloadOps({required this.status, required this.operations});
  final QueueStatus status;
  final List<DownloadOp> operations;
  DownloadOps copyWith({QueueStatus? status, List<DownloadOp>? operations}) {
    return DownloadOps(
      status: status ?? this.status,
      operations: operations ?? this.operations,
    );
  }

  DownloadOps.empty() : status = QueueStatus.empty, operations = List.empty();
}

enum QueueStatus { empty, downloading, paused, error }
class DownloadsRepository {

  DownloadOps _downloads = DownloadOps.empty();
  final _downloadsStream = StreamController<DownloadOps>.broadcast();

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

  Stream<DownloadOps> get downloads async* {
    yield _downloads;
    yield *_downloadsStream.stream;
  }

  Future<void> queueDownload(ApiClient api, num gameId) async {
    // if download queue
  }

  void removeFromQueue(num gameId) {
    // if active download == gameid  --> stop and remove
  }

  void pushToFront(num gameId) {
    
  }

}