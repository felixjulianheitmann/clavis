import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginFormBlocState {
  LoginFormBlocState({this.host = '', this.user = '', this.pass = '', this.errorMessage});
  final String host;
  final String user;
  final String pass;
  final String? errorMessage;
}

class LoginFormEvent {}
class SubscribeSettings extends LoginFormEvent {}

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormBlocState> {
  final PrefRepo _prefRepo;

  LoginFormBloc({required PrefRepo prefRepo, required AuthRepository authRepo})
    : _prefRepo = prefRepo,
      super(LoginFormBlocState()) {
    on<SubscribeSettings>(_onSubscribe);
  }

  Future<void> _onSubscribe(
    SubscribeSettings state,
    Emitter<LoginFormBlocState> emit,
  ) async {
    if (_prefRepo.creds != null) {
      emit(
        LoginFormBlocState(
          host: _prefRepo.creds!.host ?? '',
          user: _prefRepo.creds!.user ?? '',
          pass: _prefRepo.creds!.pass ?? '',
        ),
      );
    } else {
      await _prefRepo.init();
    }
    await emit.onEach(
      _prefRepo.credStream,
      onData:
          (prefs) => emit(
            LoginFormBlocState(
              host: prefs.host ?? '',
              user: prefs.user ?? '',
              pass: prefs.pass ?? '',
            ),
          ),
    );
  }
}
