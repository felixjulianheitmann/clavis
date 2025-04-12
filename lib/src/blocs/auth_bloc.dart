import 'dart:async';

import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:clavis/src/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class AuthEvent {}

final class AuthSubscriptionRequested extends AuthEvent {}
final class Logout extends AuthEvent {}

class AuthState {
  AuthState(this.creds);
  Credentials? creds;
}

class Unknown extends AuthState {
  Unknown(super.creds);
}

class Unauthenticated extends AuthState {
  Unauthenticated({this.message, Credentials? creds}) : super(creds);
  final String? message;
}

class Authenticated extends AuthState {
  Authenticated({required this.api, Credentials? creds}) : super(creds);
  final ApiClient api;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthRepository authRepo, PrefRepo prefRepo)
    : _authRepo = authRepo,
      _prefRepo = prefRepo,
      super(Unknown(prefRepo.creds)) {
    on<AuthSubscriptionRequested>(_onAuthSubscription);
    on<Logout>(_onLogout);
  }

  static const _authCheckInterval = Duration(seconds: 10);

  final AuthRepository _authRepo;
  final PrefRepo _prefRepo;

  Future<void> _onAuthSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // make sure the stored values are available
    if (_prefRepo.creds != null) {
      return _doSubscription(event, emit, _prefRepo.creds!);
    }

    emit.onEach(_prefRepo.credStream, onData: (creds) => emit(Unknown(creds)));
  }

  Future<void> _doSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
    Credentials creds,
  ) async {
    // check if the user is already authenticated and set the initial state
    await _authRepo.checkAuth(creds);

    emit.onEach(
      _authRepo.status,
      onData: (status) async {
        switch (status.$1) {
          case AuthStatus.unknown:
            return emit(Unknown(creds));
          case AuthStatus.unauthenticated:
            return emit(Unauthenticated());
          case AuthStatus.authenticated:
            Timer.periodic(
              _authCheckInterval,
              (_) async =>
                  await _authRepo.checkAuth(creds),
            );
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
    _authRepo.logout();
  }
}
