import 'dart:async';

import 'package:clavis/src/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Credentials {
  Credentials({required this.host, required this.user, required this.pass});
  Credentials.empty() : host = null, user = null, pass = null;
  String? host;
  String? user;
  String? pass;

  void update({
    String? host,
    String? user,
    String? pass,
  }) {
    this.host = host ?? this.host;
    this.user = user ?? this.user;
    this.pass = pass ?? this.pass;
  }
  void clear() {
    host = null;
    user = null;
    pass = null;
  }
}

class Preferences {
  ThemeMode theme;
  LogOpts logOpts;
  String? downloadDir;
  bool launchOnBoot;
  double? gameCardWidth;

  Preferences({
    this.theme = ThemeMode.system,
    this.logOpts = const LogOpts(),
    this.downloadDir,
    this.launchOnBoot = false,
    this.gameCardWidth,
  });

  void update({
    ThemeMode? theme,
    LogOpts? logOpts,
    String? downloadDir,
    bool? launchOnBoot,
    double? gameCardWidth,
  }) {
    this.theme = theme ?? this.theme;
    this.logOpts = logOpts ?? this.logOpts;
    this.downloadDir = downloadDir ?? this.downloadDir;
    this.launchOnBoot = launchOnBoot ?? this.launchOnBoot;
    this.gameCardWidth = gameCardWidth ?? this.gameCardWidth;
  }
}

class PrefRepo {
  final _prefCtrl = StreamController<Preferences>();
  final _credCtrl = StreamController<Credentials>();
  final Preferences _prefs = Preferences();
  final Credentials _creds = Credentials.empty();

  static const _keyUsername = "username";
  static const _keyPassword = "password";
  static const _keyHostname = "hostname";
  static const _keyTheme = "app.theme";
  static const _keyLogDebug = "log.debug";
  static const _keyLogOutFile = "log.outFile";
  static const _keyDownloadDir = "games.downloadDir";
  static const _keyLaunchOnBoot = "app.launchOnBoot";
  static const _keyGameCardWidth = "app.gamecardwidth_index";

  Future<void> init() async {
    final theme = await _getTheme();
    final logOpts = await _getLogOpts();
    final downloadDir = await _getDownloadDir();
    final launchOnBoot = await _getLaunchOnBoot();
    final gameCardWidth = await _getGameCardWidth();

    final host = await _getHostname();
    final user = await _readUser();
    final pass = await _readPass();
    
    _prefs.update(
      theme: theme,
      logOpts: logOpts,
      downloadDir: downloadDir,
      launchOnBoot: launchOnBoot,
      gameCardWidth: gameCardWidth,
    );

    _creds.update(
      host: host,
      user: user,
      pass: pass,
    );
    _prefCtrl.add(_prefs);
    _credCtrl.add(_creds);
  }

  Stream<Preferences> get prefStream => _prefCtrl.stream;
  Stream<Credentials> get credStream => _credCtrl.stream;
  Preferences? get prefs => _prefs;
  Credentials? get creds => _creds;

  Future<ThemeMode> _getTheme() async {
    final themeIdx = await _get<int>(_keyTheme);
    if (themeIdx != null && themeIdx < ThemeMode.values.length) {
      return ThemeMode.values[themeIdx];
    }
    return ThemeMode.system;
  }

  Future<String?> _getHostname() async => await _get<String>(_keyHostname);
  Future<LogOpts> _getLogOpts() async {
    final debug = await _get<bool>(_keyLogDebug);
    final outFile = await _get<String>(_keyLogOutFile);
    return LogOpts(debug: debug ?? false, outFile: outFile);
  }

  Future<double?> _getGameCardWidth() async =>
      await _get<double>(_keyGameCardWidth);
  Future<String?> _getDownloadDir() async => await _get(_keyDownloadDir);
  Future<bool?> _getLaunchOnBoot() async => await _get(_keyLaunchOnBoot);

  Future<String?> _readUser() async {
    final store = FlutterSecureStorage();
    return await store.read(key: _keyUsername);
  }
  Future<String?> _readPass() async {
    final store = FlutterSecureStorage();
    return await store.read(key: _keyPassword);
  }

  Future<void> write(Credentials creds) async {
    final store = FlutterSecureStorage();
    _creds.update(host: creds.host, user: creds.user, pass: creds.pass);
    _credCtrl.add(_creds);
    await store.write(key: _keyUsername, value: creds.user);
    await store.write(key: _keyPassword, value: creds.pass);
  }

  Future<void> remove() async {
    final store = FlutterSecureStorage();
    _creds.clear();
    _credCtrl.add(_creds);
    await store.delete(key: _keyUsername);
    await store.delete(key: _keyPassword);
  }

  Future<void> setTheme(ThemeMode t) async {
    _prefs.update(theme: t);
    _prefCtrl.add(_prefs);
    await _set(_keyTheme, t.index);
  }

  Future<void> setLogOpts(LogOpts opts) async {
    _prefs.update(logOpts: opts);
    _prefCtrl.add(_prefs);
    await _set(_keyLogDebug, opts.debug);
    await _set(_keyLogOutFile, opts.outFile);
  }

  Future<void> setDownloadDir(String d) async {
    _prefs.update(downloadDir: d);
    _prefCtrl.add(_prefs);
    await _set(_keyDownloadDir, d);
  }

  Future<void> setLaunchOnBoot(bool v) async {
    _prefs.update(launchOnBoot: v);
    _prefCtrl.add(_prefs);
    await _set(_keyLaunchOnBoot, v);
  }

  Future<void> setGameCardWidth(double w) async {
    _prefs.update(gameCardWidth: w);
    _prefCtrl.add(_prefs);
    await _set(_keyGameCardWidth, w);
  }
}

Future<T?> _get<T>(String key) async {
  final store = await SharedPreferences.getInstance();
  if (T == String) {
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

Future<void> _set<T>(String key, T value) async {
  final store = await SharedPreferences.getInstance();
  if (T == String) {
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
