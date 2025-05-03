import 'dart:async';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:clavis/src/types.dart';
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

enum _ErrCode { authFailed, authFailedSavedCreds, loginFailed, logoutFailed }

class _AuthErrCode extends ClavisErrCode {
  _AuthErrCode(this.code);
  final _ErrCode code;

  @override
  String localize(AppLocalizations translate) {
    switch (code) {
      case _ErrCode.authFailed:
        return translate.error_authentication_failed;
      case _ErrCode.authFailedSavedCreds:
        return translate.error_authentication_failed_saved_creds;
      case _ErrCode.loginFailed:
        return translate.error_login_failed;
      case _ErrCode.logoutFailed:
        return translate.error_logout_failed;
    }
  }
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
      if (_prefRepo.creds != null) {
        try {
          final api = _authRepo.makeApi(_prefRepo.creds!);
          _authRepo.checkAuth(api);
        } catch (e) {
          _errorRepo.setError(
            ClavisError(_AuthErrCode(_ErrCode.authFailedSavedCreds), e),
          );
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }

      await emit.onEach(
        _authRepo.status,
        onData: (auth) async {
          if (auth.$1 == AuthStatus.authenticated) {
            if (_prefRepo.creds != null) {
              await _doSubscription(event, emit, auth.$2!);
            }
          } else if (auth.$1 == AuthStatus.unauthenticated) {
            emit(Unauthenticated());
          }
        },
      );
    } catch (e) {
      _errorRepo.setError(ClavisError(_AuthErrCode(_ErrCode.authFailed), e));
      emit(Unauthenticated());
    }
  }

  Future<void> _doSubscription(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
    ApiClient api,
  ) async {
    // check if the user is already authenticated and set the initial state
    await _authRepo.checkAuth(api);

    void startNewAuthCheckTimer(ApiClient api) {
      if (_authCheckTimer != null) _authCheckTimer!.cancel();
      _authCheckTimer = Timer.periodic(_authCheckInterval, (_) async {
        try {
          await _authRepo.checkAuth(api);
        } catch (e) {
          _errorRepo.setError(
            ClavisError(_AuthErrCode(_ErrCode.authFailed), e),
          );
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
            startNewAuthCheckTimer(api);
            return emit(Authenticated(api: status.$2!));
        }
      },
      onError: (error, stackTrace) {
        _errorRepo.setError(
          ClavisError(
            _AuthErrCode(_ErrCode.authFailed),
            error,
            stack: stackTrace,
          ),
        );
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
      _errorRepo.setError(ClavisError(_AuthErrCode(_ErrCode.logoutFailed), e));
    }
  }

  Future<void> _onLogin(Login event, Emitter<AuthState> emit) async {
    try {
      if (_authCheckTimer != null) _authCheckTimer!.cancel();
      await _authRepo.login(event.creds);
      await _prefRepo.write(event.creds);
    } catch (e) {
      _errorRepo.setError(ClavisError(_AuthErrCode(_ErrCode.loginFailed), e));
    }
  }
}
