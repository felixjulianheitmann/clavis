import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

Logger get log {
  if(Log.instance == null) {
    // return default logger
    final l = Log(LogOpts(debug: false));
    l.w("logging with uninitialized logger");
    return l;
  }

  return Log.instance!;
}

class LogOpts {
  const LogOpts({this.debug = false, this.outFile});
  final bool debug;
  final String? outFile;
}

class Log extends Logger {
  Log(LogOpts opts): super(level: opts.debug ? Level.debug : Level.info, output: _getOutput(opts.outFile), printer: PrettyPrinter()) {
    FlutterError.onError = (details) {
     FlutterError.presentError(details);
     e("Error occurred", error: details, stackTrace: details.stack); 
    };
  }

  static LogOutput? _getOutput(String? outFile) {
    if(outFile == null) {
      return null;
    }
    return FileOutput(file: File(outFile));
  }

  static void initLog(LogOpts opts) {
    Log.instance = Log(opts);
  }

  static Log? instance;
}