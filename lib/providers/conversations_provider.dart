import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../core/di/service_locator.dart';

class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) =>
      ConversationsState(
        conversations: conversations ?? this.conversations,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  ConversationsNotifier() : super(const ConversationsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await ServiceLocator.conversationDao.getAll();
      state = ConversationsState(conversations: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create(Conversation convo) async {
    await ServiceLocator.conversationDao.insert(convo);
    await load();
  }

  Future<void> delete(String id) async {
    await ServiceLocator.conversationDao.delete(id);
    await load();
  }

  Future<void> rename(String id, String newTitle) async {
    final convo = await ServiceLocator.conversationDao.getById(id);
    if (convo != null) {
      convo.updateTitle(newTitle);
      await ServiceLocator.conversationDao.update(convo);
      await load();
    }
  }

  Future<void> togglePinned(String id) async {
    final convo = await ServiceLocator.conversationDao.getById(id);
    if (convo != null) {
      convo.pinned = !convo.pinned;
      convo.updatedAt = DateTime.now();
      await ServiceLocator.conversationDao.update(convo);
      await load();
    }
  }
}

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>(
  (ref) => ConversationsNotifier(),
);
