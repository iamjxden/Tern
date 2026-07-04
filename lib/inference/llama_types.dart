class LlamaModelParams {
  final int nGpuLayers;
  final bool useMmap;
  final bool useMlock;
  final String? cacheTypeK;
  final String? cacheTypeV;

  const LlamaModelParams({
    this.nGpuLayers = 0,
    this.useMmap = true,
    this.useMlock = false,
    this.cacheTypeK,
    this.cacheTypeV,
  });

  LlamaModelParams copyWith({int? nGpuLayers, bool? useMmap, bool? useMlock}) =>
      LlamaModelParams(
        nGpuLayers: nGpuLayers ?? this.nGpuLayers,
        useMmap: useMmap ?? this.useMmap,
        useMlock: useMlock ?? this.useMlock,
        cacheTypeK: cacheTypeK,
        cacheTypeV: cacheTypeV,
      );
}

class LlamaContextParams {
  final int nCtx;
  final int nBatch;
  final int nThreads;
  final int nThreadsBatch;
  final bool embedding;
  final bool offloadKqv;

  const LlamaContextParams({
    this.nCtx = 8192,
    this.nBatch = 512,
    this.nThreads = 4,
    this.nThreadsBatch = 4,
    this.embedding = false,
    this.offloadKqv = true,
  });

  LlamaContextParams copyWith({int? nCtx, int? nBatch, int? nThreads}) =>
      LlamaContextParams(
        nCtx: nCtx ?? this.nCtx,
        nBatch: nBatch ?? this.nBatch,
        nThreads: nThreads ?? this.nThreads,
        nThreadsBatch: nThreadsBatch,
        embedding: embedding,
        offloadKqv: offloadKqv,
      );
}

class LlamaSamplerParams {
  final double temperature;
  final double topP;
  final int topK;
  final double minP;
  final double repetitionPenalty;
  final int seed;
  final List<String> stopSequences;

  const LlamaSamplerParams({
    this.temperature = 0.7,
    this.topP = 0.9,
    this.topK = 40,
    this.minP = 0.0,
    this.repetitionPenalty = 1.1,
    this.seed = -1,
    this.stopSequences = const [],
  });

  LlamaSamplerParams copyWith({
    double? temperature, double? topP, int? topK, double? repetitionPenalty}) =>
    LlamaSamplerParams(
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      topK: topK ?? this.topK,
      minP: minP,
      repetitionPenalty: repetitionPenalty ?? this.repetitionPenalty,
      seed: seed,
      stopSequences: stopSequences,
    );
}

class LlamaModelInfo {
  final String name;
  final String path;
  final int totalSizeBytes;
  final int parameterCount;
  final int contextSize;
  final String architecture;
  final String quantization;
  final bool isLoaded;

  const LlamaModelInfo({
    required this.name,
    required this.path,
    required this.totalSizeBytes,
    required this.parameterCount,
    required this.contextSize,
    this.architecture = 'llama',
    this.quantization = 'Q4_K_M',
    this.isLoaded = false,
  });
}

class InferenceStats {
  final int tokensGenerated;
  final Duration elapsed;
  final int promptTokens;
  final int contextUsed;

  const InferenceStats({
    this.tokensGenerated = 0,
    this.elapsed = Duration.zero,
    this.promptTokens = 0,
    this.contextUsed = 0,
  });

  double get tokensPerSecond =>
      elapsed.inMilliseconds > 0
          ? tokensGenerated / elapsed.inMilliseconds * 1000
          : 0.0;

  double get contextUsagePct =>
      contextUsed > 0 ? promptTokens / contextUsed : 0.0;
}
