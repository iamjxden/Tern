extension ListExt<T> on List<T> {
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size > length) ? length : i + size));
    }
    return chunks;
  }

  T? get middle => isEmpty ? null : this[length ~/ 2];

  List<T> sortedBy(Comparable Function(T e) keyOf) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keyOf(a).compareTo(keyOf(b)));
    return copy;
  }

  List<T> sortedByDescending(Comparable Function(T e) keyOf) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keyOf(b).compareTo(keyOf(a)));
    return copy;
  }

  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  Map<K, List<T>> groupBy<K>(K Function(T e) keyOf) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyOf(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}
