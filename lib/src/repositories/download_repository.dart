

import 'dart:async';

class DownloadState {}
typedef DownloadStates = Map<num, DownloadState>;

class DownloadsRepository {

  final _downloads = DownloadStates();
  final _downloadsStream = StreamController<DownloadStates>();

  Stream<DownloadStates> get downloads async* {
    yield _downloads;
    yield *_downloadsStream.stream;
  }



}