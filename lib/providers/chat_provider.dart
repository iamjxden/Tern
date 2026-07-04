import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/model_preset.dart';
import '../core/di/service_locator.dart';

class ChatState {
  final Conversation? conversation;
  final List<Message> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;
  final ModelPreset? activePreset;

  const ChatState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
    this.activePreset,
  });

  ChatState copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? isLoading,
    bool? isStreaming,
    Object? error = _sentinel,
    ModelPreset? activePreset,
  }) =>
      ChatState(
        conversation: conversation ?? this.conversation,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isStreaming: isStreaming ?? this.isStreaming,
        error: identical(error, _sentinel) ? this.error : error as String?,
        activePreset: activePreset ?? this.activePreset,
      );
}

const Object _sentinel = Object();

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  void newConversation() {
    final convo = Conversation.create();
    state = ChatState(conversation: convo);
  }

  void selectConversation(Conversation convo) {
    state = ChatState(conversation: convo, messages: List.from(convo.messages));
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty) return;
    if (state.conversation == null) newConversation();
    final msg =
        Message.user(content, conversationId: state.conversation!.id);
    state.conversation!.addMessage(msg);
    state = state.copyWith(
      messages: List.from(state.messages)..add(msg),
      isLoading: true,
      error: null,
    );
    ServiceLocator.messageDao.insert(msg);
  }

  void receiveAssistantStream(String chunk) {
    if (state.conversation == null) return;
    if (!state.isStreaming) {
      final msg = Message.assistant(chunk,
          conversationId: state.conversation!.id);
      state.conversation!.addMessage(msg);
      state = state.copyWith(
        messages: List.from(state.messages)..add(msg),
        isStreaming: true,
        isLoading: false,
      );
      return;
    }
    final msgs = List<Message>.from(state.messages);
    final lastIdx = msgs.length - 1;
    if (lastIdx < 0) return;
    final last = msgs[lastIdx];
    if (last.role != 'assistant') {
      final msg = Message.assistant(chunk,
          conversationId: state.conversation!.id);
      state.conversation!.addMessage(msg);
      state = state.copyWith(messages: msgs..add(msg));
      return;
    }
    final updated = Message(
      id: last.id,
      conversationId: last.conversationId,
      role: 'assistant',
      content: last.content + chunk,
      createdAt: last.createdAt,
    );
    if (state.conversation!.messages.isNotEmpty) {
      state.conversation!.messages[state.conversation!.messages.length - 1] =
          updated;
    }
    msgs[lastIdx] = updated;
    state = state.copyWith(messages: msgs);
  }

  void finishStreaming() {
    if (state.conversation != null && state.messages.isNotEmpty) {
      final last = state.messages.last;
      if (last.role == 'assistant') {
        ServiceLocator.messageDao.insert(last);
      }
    }
    state = state.copyWith(isLoading: false, isStreaming: false);
  }

  void setError(String error) =>
      state = state.copyWith(error: error, isLoading: false, isStreaming: false);

  void clearError() => state = state.copyWith(error: null);
  void setPreset(ModelPreset preset) => state = state.copyWith(activePreset: preset);
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier());
