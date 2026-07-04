import 'dart:io';
import '../core/logger/humannode_logger.dart';

class HumanNodeTokenizer {
  final Map<String, int> _vocab = {};
  final Map<int, String> _reverseVocab = {};
  bool _loaded = false;
  String? _loadedModel;

  bool get isLoaded => _loaded;
  String? get loadedModel => _loadedModel;

  Future<void> loadVocab(String modelPath) async {
    if (_loadedModel == modelPath) return;
    _vocab.clear();
    _reverseVocab.clear();
    final vocabFile = File('$modelPath.vocab');
    if (await vocabFile.exists()) {
      try {
        final lines = await vocabFile.readAsLines();
        for (var i = 0; i < lines.length; i++) {
          _vocab[lines[i].trim()] = i;
          _reverseVocab[i] = lines[i].trim();
        }
        HumanNodeLogger.info(
            'Loaded vocab: ${lines.length} tokens from $modelPath');
      } catch (e) {
        HumanNodeLogger.warn('Failed to load vocab file, using character fallback');
      }
    }
    _loadedModel = modelPath;
    _loaded = true;
  }

  List<int> encode(String text) {
    if (!_loaded || _vocab.isEmpty) return text.codeUnits;
    final tokens = <int>[];
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      tokens.add(_vocab[char] ?? char.codeUnitAt(0));
    }
    return tokens;
  }

  String decode(List<int> tokens) {
    if (!_loaded || _reverseVocab.isEmpty) {
      return String.fromCharCodes(
          tokens.where((t) => t >= 0 && t <= 0x10FFFF));
    }
    return tokens
        .map((t) => _reverseVocab[t] ?? String.fromCharCode(t.clamp(0, 0x10FFFF)))
        .join();
  }

  int estimateTokenCount(String text) => (text.length / 3.5).ceil();

  int estimateTokenCountAccurate(String text) {
    if (!_loaded || _vocab.isEmpty) return estimateTokenCount(text);
    int count = 0;
    int i = 0;
    while (i < text.length) {
      bool found = false;
      for (int len = 4; len >= 1; len--) {
        if (i + len <= text.length) {
          final sub = text.substring(i, i + len);
          if (_vocab.containsKey(sub)) {
            count++;
            i += len;
            found = true;
            break;
          }
        }
      }
      if (!found) {
        count++;
        i++;
      }
    }
    return count;
  }
}
