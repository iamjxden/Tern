class FormatDetector {
  static bool hasCodeBlock(String text) => text.contains('```');
  static bool hasTable(String text) => text.contains('|') && text.contains('\n|');
  static bool hasLatex(String text) => text.contains(r'$$') || text.contains(r'$');
  static bool hasJson(String text) {
    final trimmed = text.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) || (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }
  static bool hasXml(String text) => text.trim().startsWith('<');
  static bool hasMarkdown(String text) =>
      text.contains('**') || text.contains('##') || text.contains('```') || text.contains('|');
}
