import 'dart:async';

import 'package:clavis/src/types.dart';

class ClavisError {
  ClavisError(this.code, this.err, {StackTrace? stack, DateTime? ts})
    : stack = stack ?? StackTrace.current,
      ts = ts ?? DateTime.now();
  final ClavisErrCode code;
  final Object err;
  final DateTime ts;
  final StackTrace stack;
}

class ErrorRepository {
  final _errorStream = StreamController<ClavisError>.broadcast();

  Stream<ClavisError> get errorStream async* {
    yield* _errorStream.stream;
  }

  void setError(ClavisError e) => _errorStream.add(e);
}
