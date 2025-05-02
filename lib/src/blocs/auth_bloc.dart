import 'dart:async';

import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
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
  Unauthenticated() : super();
}

class Authenticated extends AuthState {
  Authenticated({required this.api}) : super();
  final ApiClient api;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    AuthRepository authRepo,
    PrefRepo prefRepo,
    ErrorRepository errorRepo,
  ) : _authRepo = authRepo,
      _prefRepo = prefRepo,
      _errorRepo = errorRepo,
      super(Unknown()) {
    on<AuthSubscriptionRequested>(_onAuthSubscription);
    on<Logout>(_onLogout);
    on<Login>(_onLogin);
  }

  static const _authCheckInterval = Duration(seconds: 10);

  final AuthRepository _authRepo;
  final PrefRepo _prefRepo;
  final ErrorRepository _errorRepo;
  Timer? _authCheckTimer;

  Future<void> _onAuthSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // make sure the stored values are available
      if (_prefRepo.creds != null) {
        return await _doSubscription(event, emit, _prefRepo.creds!);
      }

      await emit.onEach(
        _prefRepo.credStream,
        onData: (creds) async => await _doSubscription(event, emit, creds),
      );
    } catch (e) {
      _errorRepo.setError(ClavisError(e));
      emit(Unauthenticated());
    }
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
      _authCheckTimer = Timer.periodic(_authCheckInterval, (_) async {
        try {
          await _authRepo.checkAuth(creds);
        } catch (e) {
          _errorRepo.setError(ClavisError(e));
        }
      });
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
        _errorRepo.setError(ClavisError(error, stack: stackTrace));
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    try {
      if (_authCheckTimer != null) _authCheckTimer!.cancel();
      await _prefRepo.remove();
      _authRepo.logout();
    } catch (e) {
      _errorRepo.setError(ClavisError(e));
    }
  }

  Future<void> _onLogin(Login event, Emitter<AuthState> emit) async {
    try {
      if (_authCheckTimer != null) _authCheckTimer!.cancel();
      await _authRepo.login(event.creds);
      await _prefRepo.write(event.creds);
    } catch (e) {
      _errorRepo.setError(ClavisError(e));
    }
  }
}
