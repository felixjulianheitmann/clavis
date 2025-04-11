import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginFormBlocState {
  LoginFormBlocState({this.host = '', this.user = '', this.pass = '', this.errorMessage});
  final String host;
  final String user;
  final String pass;
  final String? errorMessage;
}

class LoginFormEvent {}
class HostEdited extends  LoginFormEvent {
  HostEdited(this.host);
  final String host;
}
class UserEdited extends  LoginFormEvent {
  UserEdited(this.user);
  final String user;
}
class PassEdited extends  LoginFormEvent {
  PassEdited(this.pass);
  final String pass;
}

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
    on<HostEdited>((event, _) => _hostEditCtrl.text = event.host);
    on<UserEdited>((event, _) => _userEditCtrl.text = event.user);
    on<PassEdited>((event, _) => _passEditCtrl.text = event.pass);
  }

  Future<void> _onSubscribe(
    SubscribeSettings state,
    Emitter<LoginFormBlocState> emit,
  ) async {
    emit.onEach(_prefRepo.credStream, onData: (prefs) => emit(LoginFormBlocState(host: prefs.host ?? '', user: prefs.user ?? '', pass: prefs.pass ?? '')));
  }
  Future<void> _onSubmit(Submit state, Emitter<LoginFormBlocState> emit) async {
    _authRepo.login(host: state.host, user: state.user, pass: state.pass);
  }
  Future<void> _onFailed(Failed state, Emitter<LoginFormBlocState> emit) async {
        
  }
}
