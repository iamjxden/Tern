import 'package:flutter_test/flutter_test.dart';
import 'package:tern/models/message.dart';

void main() {
  group('Message', () {
    test('user factory creates user role', () {
      expect(Message.user('hi').role, 'user');
    });
    test('assistant factory creates assistant role', () {
      expect(Message.assistant('hello').role, 'assistant');
    });
    test('toolResult factory sets metadata', () {
      final m = Message.toolResult(name: 'calc', result: '42');
      expect(m.role, 'tool_result');
    });
    test('system factory creates system role', () {
      expect(Message.system('prompt').role, 'system');
    });
  });
}
