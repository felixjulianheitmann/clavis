import 'package:clavis/util/credential_store.dart';
import 'package:clavis/util/logger.dart';
import 'package:clavis/util/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/model/credentials.dart';

sealed class AuthEvent {}

final class AuthCredChangedEvent extends AuthEvent {
  AuthCredChangedEvent({this.newCreds});
  final Credentials? newCreds;
}

final class AuthChangedEvent extends AuthEvent {
  AuthChangedEvent({required this.state});
  final AuthState state;
}

final class AuthRemovedEvent extends AuthEvent {}

final class AuthStateChangedEvent extends AuthEvent {
  AuthStateChangedEvent({required this.isAuthenticated});
  final bool isAuthenticated;
}

abstract class AuthState {
  const AuthState();
}

class AuthSuccessState extends AuthState {
  const AuthSuccessState({required this.api, required this.me});
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
    on<AuthChangedEvent>((event, emit) {
      log.i("Authentication changed");
      emit(event.state);
    });

    /**
     * credentials have been deleted - logout likely
     */
    on<AuthRemovedEvent>((event, emit) {
      log.i("Authentication has been revoked");
      emit(AuthEmptyState());
    });

    /**
     * on change of credentials, check if the user can be authenticated this way
     */
    on<AuthCredChangedEvent>((event, emit) async {
      log.i(
        "Authentication credentials have been entered: ${event.newCreds?.user}",
      );
      if (event.newCreds == null) {
        await CredentialStore.remove();
        emit(AuthEmptyState());
        return;
      }

      await CredentialStore.write(event.newCreds!);

      final host = await Preferences.getHostname();
      if (host == null) {
        log.w("authentication failed - no host available");
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
          log.e("authentication failed - querying user info failed");
          emit(AuthFailedState("couldn't query user info"));
          return;
        }

        emit(AuthSuccessState(api: api, me: me));
      } catch (e) {
        log.e("authentication failed - querying user info failed", error: e);
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
    try {
      final me = await UserApi(api).getUsersMe();
      if (me == null) {
        log.w("initial user credentials couldn't query users");
        return Future.value(AuthFailedState("Couldn't query users"));
      }
      return Future.value(AuthSuccessState(api: api, me: me));
    } catch (e) {
      log.w("initial user credentials couldn't query users", error: e);
      return Future.value(AuthFailedState("Couldn't query users"));
    }
  }
}
