class HumanNodeException implements Exception {
  final String message;
  final String? detail;
  final StackTrace? stackTrace;
  final Object? cause;

  const HumanNodeException(this.message, {this.detail, this.stackTrace, this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('HumanNodeException: $message');
    if (detail != null) buffer.write(' ($detail)');
    if (cause != null) buffer.write(' [cause: $cause]');
    return buffer.toString();
  }
}
