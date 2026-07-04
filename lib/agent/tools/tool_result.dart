sealed class ToolResult<T> {
  const ToolResult();
}

class ToolSuccess<T> extends ToolResult<T> {
  final T data;
  final Duration? elapsed;

  const ToolSuccess(this.data, {this.elapsed});

  @override String toString() => data.toString();
}

class ToolFailure extends ToolResult<Never> {
  final String error;
  final String? detail;

  const ToolFailure(this.error, {this.detail});

  @override String toString() => detail != null ? '$error ($detail)' : error;
}
