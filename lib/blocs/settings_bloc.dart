import 'package:clavis/util/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsEvent {}
class Subscribe extends SettingsEvent {}

class SettingsState {}
class Unknown extends SettingsState {}
class Ready extends SettingsState {
  Ready({required this.settings});
  final AppSettings settings;
}


class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(Unknown()) {
    on<Subscribe>((event, emit) {
      emit.onEach()
      emit(Ready(settings: event.settings));
      await Preferences.setAppSettings(event.settings);
    });
  }
}