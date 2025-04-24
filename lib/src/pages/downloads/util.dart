import 'dart:collection';

extension WindowExtension<T> on Iterable<T> {
  Iterable<List<T>> window(int length) sync* {
    if (length < 1) throw RangeError.range(length, 1, null, 'length');

    var iterator = this.iterator;
    final window = Queue<T>();
    while (iterator.moveNext()) {
      if (window.length == length) window.removeFirst();
      window.addLast(iterator.current);
      if (window.length < length) continue;

      yield window.toList();
    }
  }
}

double downloadSpeed(List<(int, DateTime)> downloadHistory) {
  if (downloadHistory.length <= 1) return 0.0;

  final duration = downloadHistory.last.$2.difference(downloadHistory.first.$2);
  final bytes = downloadHistory.last.$1 - downloadHistory.first.$1;
  return duration.inMicroseconds > 0
      ? bytes / duration.inMicroseconds * 1000000
      : 0.0;
}

List<double> windowAverage(List<double> values, int windowLength) {
  if (windowLength < 1) throw ArgumentError("don't average 0-length windows");
  final window = Queue<double>.from(List<double>.filled(windowLength, 0.0));
  return values.map((v) {
    window.removeLast();
    window.addFirst(v);
    return window.reduce((a, b) => a + b) / windowLength;
  }).toList();
}
