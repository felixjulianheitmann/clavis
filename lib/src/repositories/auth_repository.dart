import 'dart:async';

import 'package:clavis/src/util/logger.dart';
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
  final _controller = StreamController<(AuthStatus, ApiClient?)>();
  ApiClient? _api;

  Stream<(AuthStatus, ApiClient?)> get status async* {
    if (_api == null) {
      yield (AuthStatus.unknown, null);
    } else {
      yield (AuthStatus.authenticated, _api);
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
    if (await UserApi(api).getUsersMe() == null) {
      _controller.add((AuthStatus.unauthenticated, null));
    }
  }

  Future<void> login(Credentials creds) async {
    if (creds.host == null || creds.user == null || creds.pass == null) return;

    final auth = HttpBasicAuth(password: creds.pass!, username: creds.user!);
    final api = ApiClient(basePath: creds.host!, authentication: auth);

    try {
      if (await UserApi(api).getUsersMe() == null) {
        log.e("authentication failed - querying user info failed");
        _controller.add((AuthStatus.unauthenticated, null));
        return;
      }

      _api = api;
      _controller.add((AuthStatus.authenticated, api));
    } catch (e) {
      log.e("authentication failed - querying user info failed", error: e);
      _controller.add((AuthStatus.unauthenticated, null));
      return;
    }
  }

  void logout() {
    _controller.add((AuthStatus.unauthenticated, null));
  }

  void dispose() => _controller.close();
}
