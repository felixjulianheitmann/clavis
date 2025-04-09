import 'dart:async';

import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class AuthEvent {}

final class AuthSubscriptionRequested extends AuthEvent {}

class AuthState {}

class Unknown extends AuthState {}

class Unauthenticated extends AuthState {
  Unauthenticated({this.message});
  final String? message;
}

class Authenticated extends AuthState {
  Authenticated({required this.api});

  final ApiClient api;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepo})
    : _authRepo = authRepo,
      super(Unknown()) {
    on<AuthSubscriptionRequested>(_onAuthSubscription);
  }

  static const _authCheckInterval = Duration(seconds: 10);

  final AuthRepository _authRepo;

  Future<void> _onAuthSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    return emit.onEach(
      _authRepo.status,
      onData: (status) async {
        switch (status.$1) {
          case AuthStatus.unknown:
            return emit(Unknown());
          case AuthStatus.unauthenticated:
            return emit(Unauthenticated());
          case AuthStatus.authenticated:
            Timer.periodic(
              _authCheckInterval,
              (timer) async => await _authRepo.checkAuth(),
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
