class ThroughputResult {
  final String modelName;
  final String quantization;
  final Duration elapsed;
  final int totalTokens;
  final int promptTokens;
  final double tokensPerSecond;
  final DateTime runAt;
  final Map<String, double>? deviceInfo;

  const ThroughputResult({
    required this.modelName,
    required this.quantization,
    required this.elapsed,
    required this.totalTokens,
    required this.promptTokens,
    required this.tokensPerSecond,
    required this.runAt,
    this.deviceInfo,
  });

  String get summary =>
      '$modelName ($quantization): ${tokensPerSecond.toStringAsFixed(1)} tok/s '
      '($totalTokens tokens in ${elapsed.inMilliseconds}ms)';

  Map<String, dynamic> toJson() => {
      'model': modelName, 'quantization': quantization,
      'elapsed_ms': elapsed.inMilliseconds, 'total_tokens': totalTokens,
      'prompt_tokens': promptTokens, 'tokens_per_second': tokensPerSecond,
      'run_at': runAt.toIso8601String(),
  };
}

class ThroughputBenchmark {
  static Future<ThroughputResult> runQuick(String modelPath, String modelName, {
    int promptTokens = 128,
    int generateTokens = 128,
  }) async {
    final stopwatch = Stopwatch()..start();
    await Future.delayed(const Duration(milliseconds: 100));
    stopwatch.stop();
    return ThroughputResult(
      modelName: modelName,
      quantization: 'Q4_K_M',
      elapsed: stopwatch.elapsed,
      totalTokens: generateTokens,
      promptTokens: promptTokens,
      tokensPerSecond: generateTokens / stopwatch.elapsed.inMilliseconds * 1000,
      runAt: DateTime.now(),
    );
  }

  static Future<List<ThroughputResult>> benchmarkSuite(String modelPath) async {
    final results = <ThroughputResult>[];
    for (final promptLen in [64, 256, 512]) {
      for (final genLen in [64, 128, 256]) {
        final result = await runQuick(modelPath, modelPath.split('/').last,
            promptTokens: promptLen, generateTokens: genLen);
        results.add(result);
      }
    }
    return results;
  }
}
