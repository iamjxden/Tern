import 'package:flutter_test/flutter_test.dart';
import 'package:tern/utils/token_counter.dart';

void main() {
  group('TokenCounter', () {
    test('empty string is 0 tokens', () {
      expect(TokenCounter.estimate(''), 0);
    });
    test('non-empty string has positive tokens', () {
      expect(TokenCounter.estimate('hello world'), greaterThan(0));
    });
    test('batch sums correctly', () {
      final tokens = TokenCounter.estimateBatch(['a', 'bb', 'ccc']);
      expect(tokens, greaterThan(0));
    });
  });
}
