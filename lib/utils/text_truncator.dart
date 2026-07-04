class TextTruncator {
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    if (maxLength <= ellipsis.length) return ellipsis.substring(0, maxLength);
    final cutAt = maxLength - ellipsis.length;
    final lastSpace = text.substring(0, cutAt).lastIndexOf(' ');
    return lastSpace > cutAt / 2 ? '${text.substring(0, lastSpace)}$ellipsis' : '${text.substring(0, cutAt)}$ellipsis';
  }

  static String truncateLines(String text, int maxLines) {
    final lines = text.split('\n');
    return lines.length <= maxLines ? text : '${lines.take(maxLines).join('\n')}\n...';
  }

  static String middle(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    final half = (maxLength - 3) ~/ 2;
    return '${text.substring(0, half)}...${text.substring(text.length - half)}';
  }
}
