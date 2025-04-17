import 'package:clavis/src/repositories/download_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class DownloadEvent{}

class DlSubscribe extends DownloadEvent{}
class DlAdd extends DownloadEvent{
  DlAdd({required this.api, required this.gameId});
  ApiClient api;
  num gameId;
}

class DlPush extends DownloadEvent{
  DlPush({required this.gameId});
  num gameId;
} 
class DlRemove extends DownloadEvent{
  DlRemove({required this.gameId});
  num gameId;
}

class DownloadState {}
class DlReady extends DownloadState {
  DlReady({required this.operations, required this.queueStatus});
  final List<DownloadOp> operations;
  final QueueStatus queueStatus;
}

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadsRepository _repo;
  
  DownloadBloc({required DownloadsRepository repo}) : _repo = repo,  super(DownloadState()) {
    on<DlSubscribe>((_, emit) async {
      await emit.onEach(_repo.downloads, onData: (queue) => emit(DlReady(operations: queue.operations, queueStatus: queue.status)));
    });

    on<DlAdd>((e, _) => _repo.queueDownload(e.api, e.gameId));
    on<DlPush>((e, _) => _repo.pushToFront(e.gameId));
    on<DlRemove>((e, _) => _repo.pushToFront(e.gameId));
  }
}