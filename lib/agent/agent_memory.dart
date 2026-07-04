import 'package:tern/storage/database.dart';
import '../models/message.dart';
import '../config/app_config.dart';

class AgentMemory {
  final MessageDao messageDao;
  final List<Message> _buffer = [];
  final List<String> _summaries = [];
  String _currentSummary = '';
  int _totalMessageCount = 0;

  AgentMemory({required this.messageDao});

  void add(Message message) {
    _buffer.add(message);
    _totalMessageCount++;
    while (_buffer.length > AppConfig.memoryWindowMessages) {
      _buffer.removeAt(0);
    }
  }

  void addSummary(String summary) {
    _summaries.add(summary);
    _currentSummary = summary;
    while (_summaries.length > 10) {
      _summaries.removeAt(0);
    }
  }

  List<Message> getRecent({int count = 20}) {
    if (_buffer.isEmpty) return [];
    final start = (_buffer.length - count).clamp(0, _buffer.length);
    final recent = _buffer.sublist(start);
    return recent;
  }

  List<Message> getAll() => List.unmodifiable(_buffer);

  String get currentSummary => _currentSummary;
  List<String> get allSummaries => List.unmodifiable(_summaries);
  int get bufferLength => _buffer.length;
  int get totalMessages => _totalMessageCount;
  bool get isEmpty => _buffer.isEmpty;

  Future<String> buildMemorySection() async {
    final recent = getRecent(count: 20);
    if (recent.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.writeln('<session_memory>');
    if (_currentSummary.isNotEmpty) {
      buffer.writeln('  <summary>$_currentSummary</summary>');
    }
    buffer.writeln('  <recent_messages>');
    for (final msg in recent.take(10)) {
      final truncated = msg.content.length > 200
          ? '${msg.content.substring(0, 200)}...'
          : msg.content;
      buffer.writeln('    <msg role="${msg.role}">$truncated</msg>');
    }
    buffer.writeln('  </recent_messages>');
    buffer.writeln('</session_memory>');
    return buffer.toString();
  }

  void clear() {
    _buffer.clear();
    _summaries.clear();
    _currentSummary = '';
  }
}
