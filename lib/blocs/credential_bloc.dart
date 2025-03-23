import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/openapi.dart';
import 'package:gamevault_web/credential_store.dart';
import 'package:gamevault_web/model/credentials.dart';
import 'package:gamevault_web/preferences.dart';

sealed class AuthEvent {}

final class AuthCredChangedEvent extends AuthEvent {
  AuthCredChangedEvent({this.newCreds});
  final Credentials? newCreds;
}

final class AuthStateChangedEvent extends AuthEvent {
  AuthStateChangedEvent({required this.isAuthenticated});
  final bool isAuthenticated;
}

final class AuthHostChangedEvent extends AuthEvent {
  AuthHostChangedEvent({required this.host});
  final String host;
}

class AuthState {
  const AuthState({
    this.creds,
    this.hostname,
    this.isAuthenticated = false,
    this.serverHealthy = false,
  });

  final Credentials? creds;
  final String? hostname;
  final bool isAuthenticated;
  final bool serverHealthy;

  AuthState copyWith({
    Credentials? creds,
    String? hostname,
    bool? isAuthenticated,
    bool? serverHealthy,
  }) {
    return AuthState(
      creds: creds ?? this.creds,
      hostname: hostname ?? this.hostname,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      serverHealthy: serverHealthy ?? this.serverHealthy,
    );
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState()) {
    /**
     * on changed host, check for healthyness
     */
    on<AuthHostChangedEvent>((event, emit) async {
      final health =
          await Openapi(
            basePathOverride: event.host,
          ).getHealthApi().getHealth();
      await Preferences.setHostname(event.host);

      if (health.statusCode == HttpStatus.ok &&
          health.data!.status == HealthStatusEnum.HEALTHY) {
        emit(state.copyWith(serverHealthy: true));
      }

      emit(state.copyWith(serverHealthy: false));
    });

    /**
     * on change of credentials, check if the user can be authenticated this way
     */
    on<AuthCredChangedEvent>((event, emit) async {
      if (event.newCreds == null) {
        await CredentialStore.remove();
        emit(AuthState());
        return;
      }

      await CredentialStore.write(event.newCreds!);

      final host = await Preferences.getHostname();
      if (host == null) {
        emit(state.copyWith(serverHealthy: false));
        return;
      }
      final api = Openapi(basePathOverride: host);
      api.setBasicAuth(
        event.newCreds!.user,
        event.newCreds!.user,
        event.newCreds!.pass,
      );
      final me = await api.getUserApi().getUsersMe();
      if (me.statusCode == HttpStatus.ok && me.data != null) {
        emit(
          state.copyWith(
            isAuthenticated: true,
            serverHealthy: true,
            creds: event.newCreds,
          ),
        );
      }

      emit(state.copyWith(isAuthenticated: false, creds: event.newCreds));
    });
  }
}
