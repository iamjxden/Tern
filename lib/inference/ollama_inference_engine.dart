import 'dart:async';
import 'ollama_client.dart';
import '../core/errors/inference_exception.dart';
import '../core/logger/humannode_logger.dart';

class GenerationResult {
  final String text;
  final Duration duration;

  const GenerationResult({required this.text, required this.duration});
}

class OllamaInferenceEngine {
  final OllamaClient client;
  bool _generating = false;

  OllamaInferenceEngine({OllamaClient? client})
      : client = client ?? OllamaClient();

  bool get isGenerating => _generating;

  Future<bool> isReady() => client.isReachable();

  Stream<String> generateStream({
    required String modelId,
    required List<OllamaChatMessage> messages,
    double temperature = 0.7,
    double topP = 0.9,
    int? maxTokens,
    String? effort,
  }) {
    _generating = true;
    final controller = StreamController<String>();

    Timer.run(() async {
      try {
        await for (final chunk in client.chatStream(
          modelId: modelId,
          messages: messages,
          temperature: temperature,
          topP: topP,
          numPredict: maxTokens,
          effort: effort,
        )) {
          if (controller.isClosed) break;
          controller.add(chunk);
        }
        if (!controller.isClosed) await controller.close();
      } catch (e, st) {
        HumanNodeLogger.error('Ollama generation failed', e, st);
        if (!controller.isClosed) {
          controller.addError(InferenceException('Generation failed: $e'));
          await controller.close();
        }
      } finally {
        _generating = false;
      }
    });

    return controller.stream;
  }

  Future<GenerationResult> generate({
    required String modelId,
    required List<OllamaChatMessage> messages,
    double temperature = 0.7,
    double topP = 0.9,
    int? maxTokens,
    String? effort,
  }) async {
    final buffer = StringBuffer();
    final stopwatch = Stopwatch()..start();
    final stream = generateStream(
      modelId: modelId,
      messages: messages,
      temperature: temperature,
      topP: topP,
      maxTokens: maxTokens,
      effort: effort,
    );
    await for (final chunk in stream) {
      buffer.write(chunk);
    }
    stopwatch.stop();
    return GenerationResult(text: buffer.toString(), duration: stopwatch.elapsed);
  }

  void stop() => _generating = false;
}
