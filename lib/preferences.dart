import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<T?> _get<T>(String key) async {
    final store = await SharedPreferences.getInstance();
    if(T == String) {
      return store.getString(key) as T?;
    } else if (T == int) {
      return store.getInt(key) as T;
    } else if (T == double) {
      return store.getDouble(key) as T;
    } else if (T == bool) {
      return store.getBool(key) as T;
    } else if (T == List<String>) {
      return store.getStringList(key) as T;
    }
    return null;
  }

  static Future<void> _set<T>(String key, T value) async {
    final store = await SharedPreferences.getInstance();
    if(T == String) {
      store.setString(key, value as String);
    } else if (T == int) {
      store.setInt(key, value as int);
    } else if (T == double) {
      store.setDouble(key, value as double);
    } else if (T == bool) {
      store.setBool(key, value as bool);
    } else if (T == List<String>) {
      store.setStringList(key, value as List<String>);
    }
  }

  static const _keyHostname = "hostname";
  static Future<String?> getHostname() async => await _get(_keyHostname);
  static Future<void> setHostname(String host) async =>await _set(_keyHostname, host);
}