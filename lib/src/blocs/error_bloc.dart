import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorState {
  const ErrorState({required this.error});
  final ClavisError? error;
  bool get hasError => error != null;
}

class ErrorEvent {}

class ErrorNew extends ErrorEvent {
  ErrorNew({required this.error});
  final ClavisError error;
}

class ErrorSubscribe extends ErrorEvent {}

class ErrorBloc extends Bloc<ErrorEvent, ErrorState> {
  final ErrorRepository _errorRepo;
  ErrorBloc(ErrorRepository errorRepo)
    : _errorRepo = errorRepo,
      super(ErrorState(error: null)) {
    on<ErrorSubscribe>((_, emit) async {
      await emit.onEach(
        _errorRepo.errorStream,
        onData: (error) {
          log.e(
            error.err.toString(),
            time: error.ts,
            stackTrace: error.err.stack,
          );
          emit(ErrorState(error: error));
        },
      );
    });

    on<ErrorNew>((event, emit) {
      log.e(
        event.error.err.toString(),
        time: event.error.ts,
      );
      emit(ErrorState(error: event.error));
    });
  }
}