import 'dart:async';
import 'llama_types.dart';
import 'package:tern/core/errors/inference_exception.dart';
import 'package:tern/core/logger/humannode_logger.dart';

class LlamaBridge {
  bool _loaded = false;
  bool _isMock = false;

  bool get isLoaded => _loaded;
  bool get isMock => _isMock;

  Future<void> load() async {
    if (_loaded) return;
    _isMock = true;
    _loaded = true;
    HumanNodeLogger.info(_isMock
        ? 'llama bridge loaded in mock mode. Build native libs for real inference.'
        : 'llama bridge loaded successfully.');
  }

  int loadModel(String path, LlamaModelParams params) {
    _checkLoaded();
    HumanNodeLogger.info('Loading model: $path (gpu_layers=${params.nGpuLayers})');
    return path.hashCode.abs();
  }

  int createContext(int modelHandle, LlamaContextParams params) {
    _checkLoaded();
    return Object.hash(modelHandle, params.nCtx, params.nBatch, params.nThreads);
  }

  Stream<String> generate(int ctxHandle, String prompt, {
    LlamaSamplerParams? sampler, int predictTokens = 2048,
    void Function(int tokens)? onToken,
  }) {
    _checkLoaded();
    final controller = StreamController<String>();
    Timer.run(() async {
      try {
        final words = prompt.split(' ');
        var tokenCount = 0;
        for (var i = 0; i < words.length && i < predictTokens && !controller.isClosed; i++) {
          controller.add(words[i]);
          tokenCount++;
          onToken?.call(tokenCount);
          if (i % 5 == 0) await Future.delayed(const Duration(milliseconds: 1));
        }
        if (!controller.isClosed && _isMock) {
          controller.add('\n\n[HumanNode - Running in mock mode. Build llama.cpp for real on-device inference.]');
        }
        if (!controller.isClosed) await controller.close();
      } catch (e) {
        if (!controller.isClosed) { controller.addError(e); await controller.close(); }
      }
    });
    return controller.stream;
  }

  List<int> tokenize(int ctxHandle, String text) { _checkLoaded(); return text.codeUnits; }

  String detokenize(int ctxHandle, List<int> tokens) {
    _checkLoaded();
    return String.fromCharCodes(tokens.where((t) => t >= 0 && t <= 0x10FFFF));
  }

  List<double> embed(int ctxHandle, String text) {
    _checkLoaded();
    final h = text.hashCode;
    return List<double>.generate(128,
        (i) => ((h * (i + 1) * 2654435761) & 0xFFFFFFFF) / 0xFFFFFFFF * 2 - 1);
  }

  List<double> getLogits(int ctxHandle) {
    _checkLoaded();
    final s = DateTime.now().millisecondsSinceEpoch;
    return List<double>.generate(32000, (i) => ((s * (i + 1)) % 1000) / 1000.0);
  }

  void unloadModel(int modelHandle) {
    _checkLoaded();
    HumanNodeLogger.info('Unloaded model: $modelHandle');
  }

  void _checkLoaded() {
    if (!_loaded) throw InferenceException('Bridge not loaded. Call load() first.');
  }
}
