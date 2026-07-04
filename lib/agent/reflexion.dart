class Reflexion {
  final int maxRetries;
  int _retryCount = 0;
  final List<_ErrorRecord> _errorHistory = [];

  Reflexion({this.maxRetries = 3});

  bool get canRetry => _retryCount < maxRetries;
  int get retryCount => _retryCount;
  List<_ErrorRecord> get errorHistory => List.unmodifiable(_errorHistory);

  String correct(String error, String originalToolCall) {
    _retryCount++;
    _errorHistory.add(_ErrorRecord(
      toolCall: originalToolCall,
      error: error,
      attempt: _retryCount,
      timestamp: DateTime.now(),
    ));

    if (_retryCount == 1) {
      return 'Previous tool call returned an error: $error\n'
          'Please analyze what went wrong and try again with corrected arguments.';
    } else if (_retryCount == 2) {
      return 'Second attempt also failed: $error\n'
          'Consider using a different approach or tool. '
          'If the task truly cannot be completed, explain why and move on.';
    } else {
      return 'Multiple attempts have failed: $error\n'
          'This tool is not working for this task. '
          'Please proceed with your best available answer and note the limitation.';
    }
  }

  String summarize() {
    if (_errorHistory.isEmpty) return 'No errors encountered.';
    return 'Errors encountered (${_errorHistory.length}):\n'
        '${_errorHistory.map((e) => '  [${e.attempt}] ${e.toolCall}: ${e.error}').join('\n')}';
  }

  void reset() {
    _retryCount = 0;
    _errorHistory.clear();
  }
}

class _ErrorRecord {
  final String toolCall;
  final String error;
  final int attempt;
  final DateTime timestamp;
  const _ErrorRecord({
    required this.toolCall,
    required this.error,
    required this.attempt,
    required this.timestamp,
  });
}
