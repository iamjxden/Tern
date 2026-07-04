import 'package:flutter_test/flutter_test.dart';
import 'package:tern/utils/format_detector.dart';

void main() {
  group('FormatDetector', () {
    test('detects code blocks with triple backtick', () {
      expect(FormatDetector.hasCodeBlock('```dart\nvar x = 1;\n```'), isTrue);
    });
    test('plain text has no code block', () {
      expect(FormatDetector.hasCodeBlock('hello world'), isFalse);
    });
    test('detects JSON objects', () {
      expect(FormatDetector.hasJson('{"key": "value"}'), isTrue);
    });
  });
}
