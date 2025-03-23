import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gamevault_web/model/credentials.dart';

class CredentialStore {
  static const _keyUsername = "username";
  static const _keyPassword = "password";

  static Future<void> write(Credentials creds) async {
    final store = FlutterSecureStorage();
    await store.write(key: _keyUsername, value: creds.user);
    await store.write(key: _keyPassword, value: creds.pass);
  }

  static Future<Credentials?> read() async {
    final store = FlutterSecureStorage();
    final user = await store.read(key: _keyUsername);
    final pass = await store.read(key: _keyPassword);
    if(user != null  && pass != null) {
      return Credentials(user: user, pass: pass);
    }

    return null;
  }

  static Future<void> remove() async {
    final store = FlutterSecureStorage();
    await store.delete(key: _keyUsername);
    await store.delete(key: _keyPassword);
  }
}