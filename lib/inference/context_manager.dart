class ContextManager {
  final int maxContextSize;
  int _currentTokens = 0;
  double _averageTokenLen = 3.5;
  int _totalTokensProcessed = 0;

  ContextManager({this.maxContextSize = 8192});

  int get remaining => maxContextSize - _currentTokens;
  bool get isFull => _currentTokens >= maxContextSize;
  bool get isNearFull => _currentTokens >= maxContextSize * 0.85;
  double get usagePercent => maxContextSize > 0 ? (_currentTokens / maxContextSize).clamp(0.0, 1.0) : 0.0;
  int get currentTokens => _currentTokens;
  int get totalTokensProcessed => _totalTokensProcessed;

  void trackTokens(int count, {int charCount = 0}) {
    if (charCount > 0 && count > 0) {
      _averageTokenLen = (_averageTokenLen * 0.95) + ((charCount / count) * 0.05);
    }
    _currentTokens += count;
    _totalTokensProcessed += count;
  }

  int trimToFit(int targetTokens) {
    if (_currentTokens <= targetTokens) return 0;
    final toRemove = _currentTokens - targetTokens;
    _currentTokens = targetTokens;
    return toRemove;
  }

  int automaticTrim() {
    if (!isNearFull) return 0;
    final target = (maxContextSize * 0.6).round();
    return trimToFit(target);
  }

  void reset() {
    _currentTokens = 0;
  }

  int estimateRemainingTokensForChars(int charCount) {
    final estTokens = (charCount / _averageTokenLen).ceil();
    return remaining - estTokens;
  }

  bool canFit(int estimatedTokens) {
    return estimatedTokens <= remaining;
  }
}
