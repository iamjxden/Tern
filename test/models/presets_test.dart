import 'package:flutter_test/flutter_test.dart';
import 'package:tern/models/model_preset.dart';

void main() {
  group('ModelPreset', () {
    test('default preset has temperature 0.7', () {
      final p = ModelPreset.defaultPreset();
      expect(p.temperature, 0.7);
    });
    test('coding preset has temperature 0.3', () {
      final p = ModelPreset.coding();
      expect(p.temperature, 0.3);
    });
    test('creative preset has temperature 1.0', () {
      final p = ModelPreset.creative();
      expect(p.temperature, 1.0);
    });
  });
}
