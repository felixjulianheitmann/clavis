import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class PrefEvent {}

final class PrefSubscribe extends PrefEvent {}
final class SetTheme extends PrefEvent {
  SetTheme({required this.theme});
  final ThemeMode theme;
}

final class SetDownloadDir extends PrefEvent {
  SetDownloadDir({required this.downloadDir});
  final String downloadDir;
}

final class SetLaunchOnBoot extends PrefEvent {
  SetLaunchOnBoot({required this.launchOnBoot});
  final bool launchOnBoot;
}

final class SetUsername extends PrefEvent {
  SetUsername({required this.username});
  final String username;
}

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
    on<SetDownloadDir>((e, _) => _prefRepo.setDownloadDir(e.downloadDir));
    on<SetTheme>((e, _) => _prefRepo.setTheme(e.theme));
    on<SetLaunchOnBoot>((e, _) => _prefRepo.setLaunchOnBoot(e.launchOnBoot));
    on<SetUsername>((e, _) => _prefRepo.writeUsername(e.username));
  }

  Future<void> _onPrefSubscribe(
    PrefSubscribe event,
    Emitter<PrefState> emit,
  ) async {
    _prefRepo.init();
    await emit.onEach(
      _prefRepo.prefStream,
      onData: (preferences) {
        emit(PrefState(preferences: preferences, status: Status.ready));
    });
  }
}
