import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/credential_store.dart';
import 'package:clavis/model/credentials.dart';
import 'package:clavis/preferences.dart';

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

abstract class AuthState {
  const AuthState();
}

class AuthSuccessfulState extends AuthState {
  const AuthSuccessfulState({required this.api, required this.me});
  final ApiClient api;
  final GamevaultUser me;
}

class AuthFailedState extends AuthState {
  const AuthFailedState(this.message);
  final String message;
}

class AuthPendingState extends AuthState {}

class AuthEmptyState extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthPendingState()) {
    /**
     * a full-on different authentication state became available
     * usually on application start
     */
    on<AuthChangedEvent>((event, emit) => emit(event.state));

    /**
     * on change of credentials, check if the user can be authenticated this way
     */
    on<AuthCredChangedEvent>((event, emit) async {
      if (event.newCreds == null) {
        await CredentialStore.remove();
        emit(AuthEmptyState());
        return;
      }

      await CredentialStore.write(event.newCreds!);

      final host = await Preferences.getHostname();
      if (host == null) {
        emit(AuthEmptyState());
        return;
      }

      final auth = HttpBasicAuth(
        password: event.newCreds!.pass,
        username: event.newCreds!.user,
      );
      final api = ApiClient(basePath: host, authentication: auth);
      try {
        final me = await UserApi(api).getUsersMe();
        if (me == null) {
          emit(AuthFailedState("couldn't query user info"));
          return;
        }

        emit(AuthSuccessfulState(api: api, me: me));
      } catch (e) {
        emit(AuthFailedState(e.toString()));
        return;
      }

    });
  }

  static Future<AuthState> initialize() async {
    final host = await Preferences.getHostname();
    if (host == null) {
      return Future.value(AuthPendingState());
    }

    final creds = await CredentialStore.read();
    if (creds == null) {
      return Future.value(AuthPendingState());
    }

    final api = ApiClient(
      basePath: host,
      authentication: HttpBasicAuth(username: creds.user, password: creds.pass),
    );
    final me = await UserApi(api).getUsersMe();
    if (me == null) {
      return Future.value(AuthFailedState("Couldn't query users"));
    }

    return Future.value(
      AuthSuccessfulState(api: api, me: me),
    );
  }

}
