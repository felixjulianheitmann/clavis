import 'package:clavis/util/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsEvent {}
class SettingsChangedEvent extends SettingsEvent {
  SettingsChangedEvent({required this.settings});
  final AppSettings settings;
}

class SettingsState {}
class SettingsLoadingState extends SettingsState {}
class SettingsLoadedState extends SettingsState{
  SettingsLoadedState({required this.settings});
  final AppSettings settings;
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsLoadingState()) {
    on<SettingsChangedEvent>((event, emit) {
      emit(SettingsLoadedState(settings: event.settings));
    });
  }
}