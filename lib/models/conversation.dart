import 'message.dart';

class Conversation {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  String modelId;
  String systemPrompt;
  bool pinned;
  bool isArchived;
  List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.modelId = '',
    this.systemPrompt = '',
    this.pinned = false,
    this.isArchived = false,
    List<Message>? messages,
  }) : messages = messages ?? [];

  factory Conversation.create({String? id, String title = 'New Chat'}) {
    final now = DateTime.now();
    return Conversation(
      id: id ?? now.microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: now,
      updatedAt: now,
    );
  }

  void addMessage(Message msg) {
    messages.add(msg);
    updatedAt = DateTime.now();
  }

  void removeMessage(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
  }

  Message? get lastMessage => messages.isEmpty ? null : messages.last;
  Message? get firstMessage => messages.isEmpty ? null : messages.first;
  int get messageCount => messages.length;

  int estimateTotalTokens({double charsPerToken = 3.5}) {
    int total = 0;
    for (final msg in messages) {
      total += (msg.content.length / charsPerToken).ceil();
    }
    return total;
  }

  void clearMessages() {
    messages.clear();
    updatedAt = DateTime.now();
  }

  void updateTitle(String newTitle) {
    title = newTitle;
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'model_id': modelId,
        'system_prompt': systemPrompt,
        'pinned': pinned,
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        modelId: json['model_id'] as String? ?? '',
        systemPrompt: json['system_prompt'] as String? ?? '',
        pinned: json['pinned'] == 1 || json['pinned'] == true,
      );
}
