import 'dart:async';

import 'package:clavis/src/types.dart';

class ClavisError {
  ClavisError(this.code, this.err, {DateTime? ts}) : ts = ts ?? DateTime.now();
  final ClavisErrCode code;
  final ClavisException err;
  final DateTime ts;
}

class ErrorRepository {
  final _errorStream = StreamController<ClavisError>.broadcast();

  Stream<ClavisError> get errorStream async* {
    yield* _errorStream.stream;
  }

  void setError(ClavisError e) => _errorStream.add(e);
}
