import 'package:clavis/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppSettings {
  AppSettings({
    required this.downloadDir,
    required this.launchOnBoot,
    required this.theme,
  });
  String? downloadDir;
  bool launchOnBoot;
  ThemeMode theme;

  AppSettings copy({
    String? downloadDir,
    bool? launchOnBoot,
    ThemeMode? theme,
  }) {
    return AppSettings(
      downloadDir: downloadDir ?? this.downloadDir,
      launchOnBoot: launchOnBoot ?? this.launchOnBoot,
      theme: theme ?? this.theme,
    );
  }
}

class Preferences {
  static Future<T?> _get<T>(String key) async {
    final store = await SharedPreferences.getInstance();
    if(T == String) {
      return store.getString(key) as T?;
    } else if (T == int) {
      return store.getInt(key) as T?;
    } else if (T == double) {
      return store.getDouble(key) as T?;
    } else if (T == bool) {
      return store.getBool(key) as T?;
    } else if (T == List<String>) {
      return store.getStringList(key) as T?;
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

  static const _keyLogDebug = "log.debug";
  static const _keyLogOutFile = "log.outFile";
  static Future<LogOpts> getLogOpts() async {
    final debug = await _get(_keyLogDebug);
    final outFile = await _get(_keyLogOutFile);
    return LogOpts(debug: debug ?? false, outFile: outFile);
  }

  static Future<void> setLogOpts(LogOpts opts) async {
    await _set(_keyLogDebug, opts.debug);
    await _set(_keyLogOutFile, opts.outFile);
  }

  static const _keyDownloadDir = "games.downloadDir";
  static Future<String?> getDownloadDir() async => await _get(_keyDownloadDir);
  static Future<void> setDownloadDir(String d) async =>
      await _set(_keyDownloadDir, d);

  static const _keyTheme = "app.theme";
  static const _keyLaunchOnBoot = "app.launchOnBoot";
  static Future<ThemeMode?> getTheme() async {
    final idx = await _get<int>(_keyTheme);
    if (idx != null && idx < ThemeMode.values.length) {
      return ThemeMode.values[idx];
    }
    return null;
  }

  static Future<void> setTheme(ThemeMode t) async {
    await _set(_keyTheme, t.index);
  }

  static Future<bool?> getLaunchOnBoot() async => await _get(_keyLaunchOnBoot);
  static Future<void> setLaunchOnBoot(bool v) async =>
      await _set(_keyLaunchOnBoot, v);

  static Future<AppSettings> getAppSettings() async {
    return AppSettings(
      downloadDir: await getDownloadDir(),
      launchOnBoot: await getLaunchOnBoot() ?? false,
      theme: await getTheme() ?? ThemeMode.light,
    );
  }

  static Future<void> setAppSettings(AppSettings settings) async {
    if (settings.downloadDir != null) {
      await setDownloadDir(settings.downloadDir!);
    }
    await setLaunchOnBoot(settings.launchOnBoot);
    await setTheme(settings.theme);
  }
}