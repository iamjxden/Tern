extension NumExt on num {
  String get fileSizeFormatted {
    if (this < 1024) return '${toStringAsFixed(0)} B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get tokensPerSecFormatted => '${toStringAsFixed(1)} tok/s';
  String get pctFormatted => '${(this * 100).toStringAsFixed(0)}%';

  Duration get milliseconds => Duration(microseconds: (this * 1000).round());
  Duration get seconds => Duration(milliseconds: (this * 1000).round());
}
