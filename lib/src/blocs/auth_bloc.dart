import 'dart:async';

import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:clavis/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class AuthEvent {}

final class AuthSubscriptionRequested extends AuthEvent {}

class AuthState {
  AuthState(this.prefs);
  Preferences? prefs;
}

class Unknown extends AuthState {
  Unknown(super.prefs);
}

class Unauthenticated extends AuthState {
  Unauthenticated({this.message, Preferences? prefs}) : super(prefs);
  final String? message;
}

class Authenticated extends AuthState {
  Authenticated({required this.api, Preferences? prefs}) : super(prefs);
  final ApiClient api;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthRepository authRepo, PrefRepo prefRepo)
    : _authRepo = authRepo,
      _prefRepo = prefRepo,
      super(Unknown(prefRepo.prefs)) {
    on<AuthSubscriptionRequested>(_onAuthSubscription);
  }

  static const _authCheckInterval = Duration(seconds: 10);

  final AuthRepository _authRepo;
  final PrefRepo _prefRepo;

  Future<void> _onAuthSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // make sure the stored values are available
    if (_prefRepo.prefs != null) {
      return _doSubscription(event, emit, _prefRepo.prefs!);
    }

    emit.onEach(_prefRepo.stream, onData: (prefs) => emit(Unknown(prefs)));
  }

  Future<void> _doSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
    Preferences prefs,
  ) async {
    // check if the user is already authenticated and set the initial state
    await _authRepo.checkAuth(prefs.hostname, prefs.creds);

    emit.onEach(
      _authRepo.status,
      onData: (status) async {
        switch (status.$1) {
          case AuthStatus.unknown:
            return emit(Unknown(prefs));
          case AuthStatus.unauthenticated:
            return emit(Unauthenticated());
          case AuthStatus.authenticated:
            Timer.periodic(
              _authCheckInterval,
              (_) async =>
                  await _authRepo.checkAuth(prefs.hostname, prefs.creds),
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
}
