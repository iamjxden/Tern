import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../core/errors/inference_exception.dart';
import '../core/logger/humannode_logger.dart';

class OllamaChatMessage {
  final String role;
  final String content;

  const OllamaChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class OllamaModelStatus {
  final String name;
  final bool installed;
  final double? downloadProgress;
  final String? error;

  const OllamaModelStatus({
    required this.name,
    required this.installed,
    this.downloadProgress,
    this.error,
  });
}

class OllamaClient {
  final String host;
  final http.Client _http;

  OllamaClient({String? host, http.Client? client})
      : host = host ?? AppConfig.ollamaDefaultHost,
        _http = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$host$path');

  Future<bool> isReachable() async {
    try {
      final res = await _http
          .get(_uri('/api/version'))
          .timeout(AppConfig.ollamaConnectTimeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> listInstalledModels() async {
    try {
      final res = await _http
          .get(_uri('/api/tags'))
          .timeout(AppConfig.ollamaConnectTimeout);
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final models = (body['models'] as List?) ?? [];
      return models
          .map((m) => (m as Map<String, dynamic>)['name'] as String)
          .toList();
    } catch (e) {
      HumanNodeLogger.error('Failed to list Ollama models', e);
      return [];
    }
  }

  Stream<OllamaModelStatus> pullModel(String modelId) async* {
    final request = http.Request('POST', _uri('/api/pull'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'name': modelId, 'stream': true});

    try {
      final streamedResponse =
          await _http.send(request).timeout(AppConfig.ollamaConnectTimeout);

      if (streamedResponse.statusCode != 200) {
        yield OllamaModelStatus(
          name: modelId,
          installed: false,
          error: 'Ollama returned ${streamedResponse.statusCode}',
        );
        return;
      }

      await for (final line in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        try {
          final data = jsonDecode(line) as Map<String, dynamic>;
          final status = data['status'] as String? ?? '';
          final total = (data['total'] as num?)?.toDouble();
          final completed = (data['completed'] as num?)?.toDouble();
          final progress = (total != null && total > 0 && completed != null)
              ? completed / total
              : null;

          if (status == 'success') {
            yield OllamaModelStatus(
                name: modelId, installed: true, downloadProgress: 1.0);
          } else {
            yield OllamaModelStatus(
              name: modelId,
              installed: false,
              downloadProgress: progress,
            );
          }
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      yield OllamaModelStatus(name: modelId, installed: false, error: '$e');
    }
  }

  Future<void> deleteModel(String modelId) async {
    await _http
        .delete(_uri('/api/delete'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': modelId}))
        .timeout(AppConfig.ollamaConnectTimeout);
  }

  Stream<String> chatStream({
    required String modelId,
    required List<OllamaChatMessage> messages,
    double temperature = 0.7,
    double topP = 0.9,
    int? numPredict,
    String? effort,
  }) async* {
    final request = http.Request('POST', _uri('/api/chat'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': modelId,
        'messages': messages.map((m) => m.toJson()).toList(),
        'stream': true,
        'options': {
          'temperature': temperature,
          'top_p': topP,
          if (numPredict != null) 'num_predict': numPredict,
        },
        if (effort != null) 'think': effort != 'standard',
      });

    http.StreamedResponse response;
    try {
      response =
          await _http.send(request).timeout(AppConfig.ollamaReceiveTimeout);
    } catch (e) {
      throw InferenceException(
          'Could not reach Ollama at $host. Is Ollama running? ($e)');
    }

    if (response.statusCode != 200) {
      throw InferenceException('Ollama chat failed: HTTP ${response.statusCode}');
    }

    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line) as Map<String, dynamic>;
        final message = data['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String? ?? '';
        if (content.isNotEmpty) yield content;
        if (data['done'] == true) break;
      } catch (e) {
        HumanNodeLogger.error('Failed to parse Ollama stream chunk', e);
        continue;
      }
    }
  }

  void close() => _http.close();
}
