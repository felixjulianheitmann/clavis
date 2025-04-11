import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class PrefEvent {}

final class PrefSubscribe extends PrefEvent {}

enum Status { loading, ready }
class PrefState {
  PrefState({required Preferences preferences, this.status = Status.loading }) : _prefs = preferences;

  final Status status;
  final Preferences _prefs;
  Preferences get prefs {
    if(status == Status.loading) {
      throw Exception("Cannot access preferences while not loaded");
    }
    return _prefs;
  }
}

class PrefBloc extends Bloc<PrefEvent, PrefState> {
  final PrefRepo _prefRepo;

  PrefBloc(PrefRepo prefRepo) : _prefRepo = prefRepo, super(PrefState(preferences: Preferences(), status: Status.loading)) {
    on<PrefSubscribe>(_onPrefSubscribe);
  }

  Future<void> _onPrefSubscribe(
    PrefSubscribe event,
    Emitter<PrefState> emit,
  ) async {
    _prefRepo.init();
    emit.onEach(_prefRepo.stream, onData: (preferences) {
      emit(PrefState(preferences: preferences));
    });
  }
}
