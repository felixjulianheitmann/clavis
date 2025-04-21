import 'package:clavis/src/repositories/download_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveDlState {
  ActiveDlState({this.operation});
  final DownloadOp? operation;
}

class ActiveDlEvent {}

class ActiveDlSubscribe extends ActiveDlEvent {}

class ActiveDlBloc extends Bloc<ActiveDlEvent, ActiveDlState> {
  final DownloadsRepository _repo;

  ActiveDlBloc(DownloadsRepository repo)
    : _repo = repo,
      super(ActiveDlState()) {
    on<ActiveDlSubscribe>((event, emit) async {
      await emit.onEach(
        _repo.downloads,
        onData: (dlContext) {
          emit(ActiveDlState(operation: dlContext.activeOp));
        },
      );
    });
  }
}
