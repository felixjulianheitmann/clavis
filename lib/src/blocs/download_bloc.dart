import 'package:clavis/src/repositories/download_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class DownloadEvent{}

class DlSubscribe extends DownloadEvent{}
class DlAdd extends DownloadEvent{
  DlAdd({required this.api, required this.downloadDir, required this.game});
  ApiClient api;
  String downloadDir;
  GamevaultGame game;
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
  DlReady({required this.dlContext});
  final DownloadContext dlContext;
}

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadsRepository _repo;
  
  DownloadBloc({required DownloadsRepository repo}) : _repo = repo,  super(DownloadState()) {
    on<DlSubscribe>((_, emit) async {
      await emit.onEach(
        _repo.downloads,
        onData: (data) => emit(DlReady(dlContext: data)),
      );
    });

    on<DlAdd>((e, _) => _repo.queueDownload(e.api, e.downloadDir, e.game));
    on<DlPush>((e, _) => _repo.activateOp(e.gameId));
    on<DlRemove>((e, _) => _repo.removeFromQueue(e.gameId));
  }
}