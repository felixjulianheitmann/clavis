import 'dart:async';

import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:clavis/src/types.dart';
import 'package:gamevault_client_sdk/api.dart';

class AuthRepoException extends ClavisException {
  AuthRepoException(super.msg, {super.innerException, super.stack})
    : super(prefix: "AuthRepoException");
}

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthRepository {
  AuthRepository() {
    Future(() async {
      await for (final state in _controller.stream) {
        _api = state.$2;
      }
    });
  }
  final _controller = StreamController<(AuthStatus, ApiClient?)>.broadcast();
  ApiClient? _api;

  Stream<(AuthStatus, ApiClient?)> get status async* {
    if (_api != null) {
      yield (AuthStatus.authenticated, _api);
    } else {
      yield (AuthStatus.unauthenticated, null);
    }
    yield* _controller.stream;
  }

  ApiClient? get api => _api;

  ApiClient makeApi(Credentials creds) {
    final auth = HttpBasicAuth(password: creds.pass!, username: creds.user!);
    return ApiClient(basePath: creds.host!, authentication: auth);
  }

  Future<void> checkAuth(ApiClient api) async {
    GamevaultUser? me;
    try {
      me = await UserApi(api).getUsersMe();
    } catch (e, s) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw AuthRepoException(
        "credential check: couldn't authenticate",
        innerException: e,
        stack: s,
      );
    }

    if (me == null) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw AuthRepoException("credential check: authenticate returned null");
    } else {
      // if this I was unauthenticated before, authenticate me
      // don't always push to stream to not update the authentication state
      // continuously
      if (_api == null) {
        _controller.add((AuthStatus.authenticated, api));
      }
    }
  }

  Future<void> login(Credentials creds) async {
    if (creds.host == null || creds.user == null || creds.pass == null) return;

    final api = makeApi(creds);

    final GamevaultUser? me;
    try {
      me = await UserApi(api).getUsersMe();
    } catch (e, s) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw AuthRepoException(
        "authentication failed - querying user info failed",
        innerException: e,
        stack: s,
      );
    }

    if (me == null) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw AuthRepoException(
        "authentication failed - querying user info returned null",
        stack: StackTrace.current,
      );
    }

    _api = api;
    _controller.add((AuthStatus.authenticated, api));
  }

  void logout() {
    _controller.add((AuthStatus.unauthenticated, null));
  }

  void dispose() => _controller.close();
}
