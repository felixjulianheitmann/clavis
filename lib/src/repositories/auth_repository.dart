import 'dart:async';

import 'package:clavis/model/credentials.dart';
import 'package:clavis/util/credential_store.dart';
import 'package:clavis/util/logger.dart';
import 'package:clavis/util/preferences.dart';
import 'package:gamevault_client_sdk/api.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthRepository {
  final _controller = StreamController<(AuthStatus, ApiClient?)>();

  Stream<(AuthStatus, ApiClient?)> get status async* {
    yield (AuthStatus.unknown, null);
    yield* _controller.stream;
  }

  Future<void> checkAuth() async {
    final host = await SettingsRepository.getHostname();
    final creds = await CredentialStore.read();
    if (host == null || creds == null) {
      return _controller.add((AuthStatus.unauthenticated, null));
    }

    final auth = HttpBasicAuth(password: creds.pass, username: creds.user);
    final api = ApiClient(basePath: host, authentication: auth);
    if (await UserApi(api).getUsersMe() == null) {
      _controller.add((AuthStatus.unauthenticated, null));
    }
  }

  Future<void> login({
    required String host,
    required String user,
    required String pass,
  }) async {
    final auth = HttpBasicAuth(password: pass, username: user);

    final api = ApiClient(basePath: host, authentication: auth);

    try {
      if (await UserApi(api).getUsersMe() == null) {
        log.e("authentication failed - querying user info failed");
        _controller.add((AuthStatus.unauthenticated, null));
        return;
      }

      await SettingsRepository.setHostname(host);
      await CredentialStore.write(Credentials(user: user, pass: pass));
      _controller.add((AuthStatus.authenticated, api));
    } catch (e) {
      log.e("authentication failed - querying user info failed", error: e);
      _controller.add((AuthStatus.unauthenticated, null));
      return;
    }
  }

  Future<void> logout() async {
    await CredentialStore.remove();
    _controller.add((AuthStatus.unauthenticated, null));
  }

  void dispose() => _controller.close();
}
