import 'package:clavis/src/repositories/download_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class DownloadEvent {}

class DlSubscribe extends DownloadEvent {}

class DlAdd extends DownloadEvent {
  DlAdd({required this.api, required this.downloadDir, required this.game});
  ApiClient api;
  String downloadDir;
  GamevaultGame game;
}

class DlRetry extends DownloadEvent {
  DlRetry({required this.gameId});
  num gameId;
}

class DlPush extends DownloadEvent {
  DlPush({required this.gameId});
  num gameId;
}

class DlCancel extends DownloadEvent {}

class DlRemovePending extends DownloadEvent {
  DlRemovePending({required this.gameId});
  num gameId;
}

class DlRemoveClosed extends DownloadEvent {
  DlRemoveClosed({required this.gameId});
  num gameId;
}

class DownloadState {
  DownloadState({required this.dlContext});
  DownloadState.init() : dlContext = DownloadContext();
  DownloadContext dlContext;
}

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadsRepository _repo;

  DownloadBloc({required DownloadsRepository repo})
    : _repo = repo,
      super(DownloadState.init()) {
    on<DlSubscribe>((_, emit) async {
      await emit.onEach(
        _repo.downloads,
        onData: (data) => emit(DownloadState(dlContext: data)),
      );
    });

    on<DlAdd>((e, _) => _repo.queueDownload(e.api, e.downloadDir, e.game));
    on<DlPush>((e, _) => _repo.activateOp(e.gameId));
    on<DlRemovePending>((e, _) => _repo.removeFromPending(e.gameId));
    on<DlRemoveClosed>((e, _) => _repo.removeFromClosed(e.gameId));
    on<DlRetry>((e, _) => _repo.queueClosed(e.gameId));
    on<DlCancel>((e, _) => _repo.cancelActive());
  }
}
