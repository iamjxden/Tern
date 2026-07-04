class Nudge {
  static const int maxNudges = 2;
  int _nudgeCount = 0;
  final List<String> _nudgeHistory = [];

  static final List<RegExp> _intentPatterns = [
    RegExp(r'let me\s+\w+', caseSensitive: false),
    RegExp(r'i will\s+\w+', caseSensitive: false),
    RegExp(r'i should\s+\w+', caseSensitive: false),
    RegExp(r'i need to\s+\w+', caseSensitive: false),
    RegExp(r'i must\s+\w+', caseSensitive: false),
    RegExp(r'going to\s+\w+', caseSensitive: false),
  ];

  bool detectsIntent(String text) => _intentPatterns.any((p) => p.hasMatch(text));

  String? nudge(String text) {
    if (_nudgeCount >= maxNudges) return null;
    if (!detectsIntent(text)) return null;
    _nudgeCount++;
    final nudgeMsg = 'You said you would take action. Do it now.';
    _nudgeHistory.add(nudgeMsg);
    return nudgeMsg;
  }

  int get nudgeCount => _nudgeCount;
  List<String> get nudgeHistory => List.unmodifiable(_nudgeHistory);
  void reset() { _nudgeCount = 0; _nudgeHistory.clear(); }
}
