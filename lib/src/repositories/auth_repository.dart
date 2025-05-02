import 'dart:async';

import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:gamevault_client_sdk/api.dart';

class AuthRepoException implements Exception {
  AuthRepoException(this.msg);
  String msg;
  @override
  String toString() => "AuthRepoException: $msg";
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

  Future<void> checkAuth(Credentials creds) async {
    if (creds.host == null || creds.user == null || creds.pass == null) {
      return _controller.add((AuthStatus.unauthenticated, null));
    }

    final auth = HttpBasicAuth(password: creds.pass!, username: creds.user!);
    final api = ApiClient(basePath: creds.host!, authentication: auth);
    GamevaultUser? me;
    try {
      me = await UserApi(api).getUsersMe();
    } catch (e) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw ApiException.withInner(
        0,
        "credential check: couldn't authenticate",
        Exception(e.toString()),
        StackTrace.current,
      );
    }

    if (me == null) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw ApiException(0, "credential check: authenticate returned null");
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

    final auth = HttpBasicAuth(password: creds.pass!, username: creds.user!);
    final api = ApiClient(basePath: creds.host!, authentication: auth);

    final GamevaultUser? me;
    try {
      me = await UserApi(api).getUsersMe();
    } catch (e) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw ApiException.withInner(
        0,
        "authentication failed - querying user info failed",
        Exception(e.toString()),
        StackTrace.current,
      );
    }

    if (me == null) {
      _controller.add((AuthStatus.unauthenticated, null));
      throw ApiException(
        0,
        "authentication failed - querying user info returned null",
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
