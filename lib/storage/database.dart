import 'package:tern/models/conversation.dart';
import 'package:tern/models/message.dart';
import 'package:tern/models/model_preset.dart';

class AppDatabase {
  final List<Conversation> _convs = [];
  final List<Message> _msgs = [];
  final List<Map<String, dynamic>> _notes = [];
  final List<ModelPreset> _presets = [];
  final Map<String, String> _settings = {};

  late final ConversationDao conversationDao;
  late final MessageDao messageDao;
  late final NoteDao noteDao;
  late final PresetDao presetDao;
  late final SettingsDao settingsDao;

  AppDatabase() {
    conversationDao = ConversationDao(this);
    messageDao = MessageDao(this);
    noteDao = NoteDao(this);
    presetDao = PresetDao(this);
    settingsDao = SettingsDao(this);
  }

  List<Conversation> get conversations => _convs;
  List<Message> get messages => _msgs;
  List<Map<String, dynamic>> get notes => _notes;
  List<ModelPreset> get presets => _presets;
  Map<String, String> get settings => _settings;

  Future<void> close() async {}
}

class ConversationDao {
  final AppDatabase _db;
  ConversationDao(this._db);

  Future<List<Conversation>> getAll({bool includeArchived = false}) async {
    final filtered = _db.conversations
        .where((c) => includeArchived || !c.isArchived)
        .toList();
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  Future<Conversation?> getById(String id) async {
    try {
      return _db.conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> insert(Conversation c) async => _db.conversations.add(c);

  Future<void> update(Conversation c) async {
    final i = _db.conversations.indexWhere((x) => x.id == c.id);
    if (i >= 0) _db.conversations[i] = c;
  }

  Future<void> delete(String id) async {
    _db.conversations.removeWhere((c) => c.id == id);
    _db.messages.removeWhere((m) => m.conversationId == id);
  }
}

class MessageDao {
  final AppDatabase _db;
  MessageDao(this._db);

  Future<List<Message>> getByConversation(String convId, {int? limit}) async {
    var msgs =
        _db.messages.where((m) => m.conversationId == convId).toList();
    msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (limit != null) msgs = msgs.take(limit).toList();
    return msgs;
  }

  Future<void> insert(Message m) async => _db.messages.add(m);

  Future<void> deleteByConversation(String convId) async =>
      _db.messages.removeWhere((m) => m.conversationId == convId);

  Future<int> count(String convId) async =>
      _db.messages.where((m) => m.conversationId == convId).length;
}

class NoteDao {
  final AppDatabase _db;
  NoteDao(this._db);

  Future<List<Map<String, dynamic>>> getAll() async => List.from(_db.notes);

  Future<void> insert(String id, String title, String content) async {
    _db.notes.insert(0, {
      'id': id,
      'title': title,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> update(String id, String title, String content) async {
    final i = _db.notes.indexWhere((n) => n['id'] == id);
    if (i >= 0) {
      _db.notes[i]['title'] = title;
      _db.notes[i]['content'] = content;
      _db.notes[i]['updated_at'] = DateTime.now().toIso8601String();
    }
  }

  Future<void> delete(String id) async =>
      _db.notes.removeWhere((n) => n['id'] == id);
}

class PresetDao {
  final AppDatabase _db;
  PresetDao(this._db);

  Future<List<ModelPreset>> getAll() async => List.from(_db.presets);
  Future<void> insert(ModelPreset p) async => _db.presets.add(p);
  Future<void> delete(String id) async =>
      _db.presets.removeWhere((p) => p.id == id);
}

class SettingsDao {
  final AppDatabase _db;
  SettingsDao(this._db);

  Future<String?> get(String key) async => _db.settings[key];
  Future<void> set(String key, String value) async =>
      _db.settings[key] = value;
  Future<void> delete(String key) async => _db.settings.remove(key);
  Future<Map<String, String>> getAll() async =>
      Map.unmodifiable(_db.settings);
}
