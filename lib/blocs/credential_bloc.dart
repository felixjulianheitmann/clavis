import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:gamevault_web/credential_store.dart';
import 'package:gamevault_web/model/credentials.dart';
import 'package:gamevault_web/preferences.dart';

sealed class AuthEvent {}

final class AuthCredChangedEvent extends AuthEvent {
  AuthCredChangedEvent({this.newCreds});
  final Credentials? newCreds;
}

final class AuthChangedEvent extends AuthEvent {
  AuthChangedEvent({required this.state});
  final AuthState state;
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
    this.serverHealthy = false,
    this.api,
  });

  final Credentials? creds;
  final String? hostname;
  final bool serverHealthy;
  final ApiClient? api;

  AuthState copyWith({
    Credentials? creds,
    String? hostname,
    bool? serverHealthy,
    ApiClient? api,
  }) {
    return AuthState(
      creds: creds ?? this.creds,
      hostname: hostname ?? this.hostname,
      api: api ?? this.api,
      serverHealthy: serverHealthy ?? this.serverHealthy,
    );
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState()) {
    /**
     * a full-on different authentication state became available
     * usually on application start
     */
    on<AuthChangedEvent>((event, emit) => emit(event.state));

    /**
     * on changed host, check for healthyness
     */
    on<AuthHostChangedEvent>((event, emit) async {
      await Preferences.setHostname(event.host);

      final api = ApiClient(basePath: event.host);
      final health = await HealthApi(api).getHealth();
      if (health != null && health.status == HealthStatusEnum.HEALTHY) {
        emit(state.copyWith(hostname: event.host, serverHealthy: true));
      }
      emit(state.copyWith(hostname: event.host, serverHealthy: false));
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
      final auth = HttpBasicAuth(
        password: event.newCreds!.pass,
        username: event.newCreds!.user,
      );
      final api = ApiClient(basePath: host, authentication: auth);
      final me = await UserApi(api).getUsersMe();
      if (me != null) {
        emit(
          state.copyWith(
            creds: event.newCreds,
            serverHealthy: true, api: api,
          ),
        );
      }

      emit(
        state.copyWith(creds: event.newCreds, api: null, serverHealthy: true),
      );
    });
  }

  Future<AuthState> initialize() async {
    final host = await Preferences.getHostname();
    if (host == null) {
      return Future.error("missing host");
    }

    final creds = await CredentialStore.read();
    if (creds == null) {
      return Future.error("missing credentials");
    }

    final api = ApiClient(
      basePath: host,
      authentication: HttpBasicAuth(username: creds.user, password: creds.pass),
    );
    final me = await UserApi(api).getUsersMe();
    if (me == null) {
      return Future.error("authentication failed");
    }

    return Future.value(
      AuthState(api: api, creds: creds, hostname: host, serverHealthy: true),
    );
  }

}
