class ToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> args;
  String? result;
  bool? success;
  DateTime? executedAt;
  Duration? elapsed;

  ToolCall({
    required this.name,
    required this.args,
    String? id,
    this.result,
    this.success,
    this.executedAt,
    this.elapsed,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
        name: json['name'] as String,
        args: json['args'] as Map<String, dynamic>? ?? {},
        id: json['id'] as String?,
        result: json['result'] as String?,
        success: json['success'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'args': args,
        if (result != null) 'result': result,
        if (success != null) 'success': success,
        if (elapsed != null) 'elapsed_ms': elapsed!.inMilliseconds,
      };
}
