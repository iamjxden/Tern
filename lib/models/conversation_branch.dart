import 'message.dart';

class ConversationBranch {
  final String branchId;
  final String parentMessageId;
  final List<Message> messages;
  final DateTime createdAt;

  const ConversationBranch({
    required this.branchId,
    required this.parentMessageId,
    required this.messages,
    required this.createdAt,
  });

  factory ConversationBranch.fromParent(Message parent, List<Message> branchMessages) {
    return ConversationBranch(
      branchId: DateTime.now().microsecondsSinceEpoch.toString(),
      parentMessageId: parent.id,
      messages: branchMessages,
      createdAt: DateTime.now(),
    );
  }
}
