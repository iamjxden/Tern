class Message {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final Map<String, dynamic>? toolCallJson;
  final String? parentId;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.toolCallJson,
    this.parentId,
    required this.createdAt,
  });

  factory Message.user(String content, {String? conversationId, String? id}) {
    final now = DateTime.now();
    return Message(
      id: id ?? now.microsecondsSinceEpoch.toString(),
      conversationId: conversationId ?? '',
      role: 'user',
      content: content,
      createdAt: now,
    );
  }

  factory Message.assistant(String content, {String? conversationId, String? id}) {
    final now = DateTime.now();
    return Message(
      id: id ?? now.microsecondsSinceEpoch.toString(),
      conversationId: conversationId ?? '',
      role: 'assistant',
      content: content,
      createdAt: now,
    );
  }

  factory Message.system(String content, {String? conversationId}) {
    return Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: conversationId ?? '',
      role: 'system',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  factory Message.toolResult({required String name, required String result, String? conversationId}) {
    return Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: conversationId ?? '',
      role: 'tool_result',
      content: result,
      toolCallJson: {'tool_name': name},
      createdAt: DateTime.now(),
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';
  bool get isToolResult => role == 'tool_result';

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'role': role,
        'content': content,
        'tool_calls_json': toolCallJson,
        'parent_id': parentId,
        'created_at': createdAt.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        toolCallJson: json['tool_calls_json'] as Map<String, dynamic>?,
        parentId: json['parent_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
