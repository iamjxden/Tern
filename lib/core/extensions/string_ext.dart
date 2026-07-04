extension StringExt on String {
  String get trimIndent {
    final lines = split('\n');
    if (lines.length <= 1) return trim();
    int? minIndent;
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final indent = line.length - line.trimLeft().length;
      minIndent = minIndent == null ? indent : (indent < minIndent ? indent : minIndent);
    }
    if (minIndent == null || minIndent == 0) return this;
    final m = minIndent;
    return lines.map((l) => l.length >= m ? l.substring(m) : l).join('\n');
  }

  int get tokenCountApprox => (length / 3.5).ceil();

  String get toSlug => toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    if (maxLength <= ellipsis.length) return ellipsis.substring(0, maxLength);
    final cutAt = maxLength - ellipsis.length;
    final lastSpace = substring(0, cutAt).lastIndexOf(' ');
    if (lastSpace > cutAt / 2) return '${substring(0, lastSpace)}$ellipsis';
    return '${substring(0, cutAt)}$ellipsis';
  }

  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
