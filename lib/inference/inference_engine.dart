import 'dart:async';
import 'llama_bridge.dart';
import 'llama_types.dart';
import 'model_loader.dart';
import 'sampler.dart';
import 'tokenizer.dart';
import '../core/errors/inference_exception.dart';
import '../core/logger/humannode_logger.dart';

class GenerationResult {
  final String text;
  final int tokensGenerated;
  final Duration duration;
  final int promptTokens;
  final int contextUsed;

  const GenerationResult({
    required this.text,
    required this.tokensGenerated,
    required this.duration,
    this.promptTokens = 0,
    this.contextUsed = 0,
  });

  double get tokensPerSecond =>
      duration.inMilliseconds > 0
          ? tokensGenerated / duration.inMilliseconds * 1000
          : 0.0;

  String get summary =>
      '$tokensGenerated tokens in ${duration.inMilliseconds}ms '
      '(${tokensPerSecond.toStringAsFixed(1)} tok/s)';
}

class InferenceEngine {
  final LlamaBridge llamaBridge;
  final ModelLoader modelLoader;
  final HumanNodeTokenizer tokenizer;
  final Sampler sampler = Sampler();
  int? _currentContext;

  InferenceEngine({
    required this.llamaBridge,
    required this.modelLoader,
    required this.tokenizer,
  });

  Future<Stream<String>> generateStream(
    String prompt, {
    String? modelPath,
    LlamaContextParams? contextParams,
    LlamaSamplerParams? samplerParams,
    void Function(int tokensGenerated)? onToken,
    int? predictTokens,
  }) async {
    if (modelPath == null || !modelLoader.isLoaded(modelPath)) {
      throw InferenceException('No model loaded. Load a model via ModelLoader first.');
    }
    final handle = modelLoader.getHandle(modelPath);
    if (handle == null) {
      throw InferenceException('Model handle not found for path: $modelPath');
    }

    await tokenizer.loadVocab(modelPath);

    final ctxParams = contextParams ?? const LlamaContextParams();
    final ctx = llamaBridge.createContext(handle, ctxParams);
    _currentContext = ctx;

    final smpParams = samplerParams ?? const LlamaSamplerParams();
    final controller = StreamController<String>();
    int tokenCount = 0;

    Timer.run(() async {
      try {
        await for (final chunk in llamaBridge.generate(
          ctx,
          prompt,
          sampler: smpParams,
          predictTokens: predictTokens ?? 2048,
          onToken: (tokens) {
            tokenCount = tokens;
            onToken?.call(tokens);
          },
        )) {
          if (controller.isClosed) break;
          controller.add(chunk);
        }
        if (!controller.isClosed) await controller.close();
        HumanNodeLogger.info('Generation complete: $tokenCount tokens');
      } catch (e, st) {
        HumanNodeLogger.error('Generation failed', e, st);
        if (!controller.isClosed) {
          controller.addError(InferenceException('Generation failed: $e'));
          await controller.close();
        }
      }
    });

    return controller.stream;
  }

  Future<GenerationResult> generate(
    String prompt, {
    String? modelPath,
    LlamaContextParams? contextParams,
    LlamaSamplerParams? samplerParams,
    int? predictTokens,
  }) async {
    final buffer = StringBuffer();
    final stopwatch = Stopwatch()..start();
    int tokens = 0;
    final stream = await generateStream(
      prompt,
      modelPath: modelPath,
      contextParams: contextParams,
      samplerParams: samplerParams,
      predictTokens: predictTokens,
      onToken: (t) => tokens = t,
    );
    try {
      await for (final chunk in stream) {
        buffer.write(chunk);
      }
    } catch (e) {
      stopwatch.stop();
      throw InferenceException('Generate failed: $e');
    }
    stopwatch.stop();
    final promptTokens = tokenizer.estimateTokenCount(prompt);
    return GenerationResult(
      text: buffer.toString(),
      tokensGenerated: tokens,
      duration: stopwatch.elapsed,
      promptTokens: promptTokens,
      contextUsed: contextParams?.nCtx ?? 8192,
    );
  }

  Future<List<double>> getEmbedding(String text, {String? modelPath}) async {
    if (modelPath == null || !modelLoader.isLoaded(modelPath)) {
      throw InferenceException('No model loaded');
    }
    final handle = modelLoader.getHandle(modelPath);
    if (handle == null) throw InferenceException('Model handle not found');
    final ctx = llamaBridge.createContext(
        handle, const LlamaContextParams(embedding: true));
    return llamaBridge.embed(ctx, text);
  }

  Future<List<double>> getLogits({String? modelPath}) async {
    if (_currentContext == null) {
      throw InferenceException('No active generation context');
    }
    return llamaBridge.getLogits(_currentContext!);
  }

  void stop() => _currentContext = null;

  bool get isGenerating => _currentContext != null;
  int? get currentContext => _currentContext;
}
