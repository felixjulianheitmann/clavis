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

class Submit extends LoginFormEvent {
  Submit({required this.host, required this.user, required this.pass});
  final String host;
  final String user;
  final String pass;
}

class Failed extends LoginFormEvent {
  Failed({this.message});
  String? message;
}

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormBlocState> {
  final PrefRepo _prefRepo;
  final AuthRepository _authRepo;

  LoginFormBloc({required PrefRepo prefRepo, required AuthRepository authRepo})
    : _prefRepo = prefRepo,
      _authRepo = authRepo,
      super(LoginFormBlocState()) {
    on<SubscribeSettings>(_onSubscribe);
    on<Submit>(_onSubmit);
    on<Failed>(_onFailed);
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
  Future<void> _onSubmit(Submit state, Emitter<LoginFormBlocState> emit) async {
    _authRepo.login(
      Credentials(host: state.host, user: state.user, pass: state.pass),
    );
  }
  Future<void> _onFailed(Failed state, Emitter<LoginFormBlocState> emit) async {
        
  }
}
