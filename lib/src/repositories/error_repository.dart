import 'dart:async';

class ClavisError {
  ClavisError(this.err, {this.stack, DateTime? ts}) : ts = ts ?? DateTime.now();
  final Object err;
  final DateTime ts;
  final StackTrace? stack;
}

class ErrorRepository {
  final _errorStream = StreamController<ClavisError>.broadcast();

  Stream<ClavisError> get errorStream async* {
    yield* _errorStream.stream;
  }

  void setError(ClavisError e) => _errorStream.add(e);
}
