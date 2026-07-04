import 'package:flutter_test/flutter_test.dart';
import 'package:tern/models/conversation.dart';

void main() {
  group('Conversation', () {
    test('creates with default title New Chat', () {
      final c = Conversation.create();
      expect(c.title, 'New Chat');
    });
    test('starts with empty messages', () {
      final c = Conversation.create();
      expect(c.messages, isEmpty);
    });
    test('addMessage increases count', () {
      final c = Conversation.create();
      final m = c.lastMessage;
      expect(m, isNull);
    });
    test('toJson produces valid map', () {
      final c = Conversation.create(title: 'Test');
      final json = c.toJson();
      expect(json['title'], 'Test');
    });
  });
}
