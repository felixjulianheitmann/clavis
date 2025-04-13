import 'dart:async';

import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:clavis/src/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class AuthEvent {}

final class AuthSubscriptionRequested extends AuthEvent {}
final class Logout extends AuthEvent {}
final class Login extends AuthEvent {
  Login({required this.creds});
  final Credentials creds;
}

class AuthState {}

class Unknown extends AuthState {}

class Unauthenticated extends AuthState {
  Unauthenticated({this.message}) : super();
  final String? message;
}

class Authenticated extends AuthState {
  Authenticated({required this.api}) : super();
  final ApiClient api;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthRepository authRepo, PrefRepo prefRepo)
    : _authRepo = authRepo,
      _prefRepo = prefRepo,
      super(Unknown()) {
    on<AuthSubscriptionRequested>(_onAuthSubscription);
    on<Logout>(_onLogout);
    on<Login>(_onLogin);
  }

  static const _authCheckInterval = Duration(seconds: 10);

  final AuthRepository _authRepo;
  final PrefRepo _prefRepo;
  Timer? _authCheckTimer;

  Future<void> _onAuthSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // make sure the stored values are available
    if (_prefRepo.creds != null) {
      return _doSubscription(event, emit, _prefRepo.creds!);
    }

    await emit.onEach(
      _prefRepo.credStream,
      onData: (creds) => _doSubscription(event, emit, creds),
    );
  }

  Future<void> _doSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
    Credentials creds,
  ) async {
    // check if the user is already authenticated and set the initial state
    await _authRepo.checkAuth(creds);

    void startNewAuthCheckTimer(Credentials creds) {
      if (_authCheckTimer != null) _authCheckTimer!.cancel();
      _authCheckTimer = Timer.periodic(
        _authCheckInterval,
        (_) async {
        await _authRepo.checkAuth(creds);
      },
      );
    }

    await emit.onEach(
      _authRepo.status,
      onData: (status) async {
        switch (status.$1) {
          case AuthStatus.unknown:
            return emit(Unknown());
          case AuthStatus.unauthenticated:
            return emit(Unauthenticated());
          case AuthStatus.authenticated:
            startNewAuthCheckTimer(creds);
            return emit(Authenticated(api: status.$2!));
        }
      },
      onError: (error, stackTrace) {
        log.e(
          "Error during authentication subscription",
          error: error,
          stackTrace: stackTrace,
        );
        emit(Unauthenticated(message: error.toString()));
      },
    );
  }

  Future<void> _onLogout(
    Logout event,
    Emitter<AuthState> emit,
  ) async {
    if (_authCheckTimer != null) _authCheckTimer!.cancel();
    _authRepo.logout();
  }

  Future<void> _onLogin(Login event, Emitter<AuthState> emit) async {
    if (_authCheckTimer != null) _authCheckTimer!.cancel();
    await _authRepo.login(event.creds);
    await _prefRepo.write(event.creds);
  }

}
