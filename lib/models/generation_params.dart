class GenerationParams {
  final double temperature;
  final double topP;
  final int topK;
  final double repetitionPenalty;
  final int maxTokens;
  final List<String> stopSequences;
  final int? seed;

  const GenerationParams({
    this.temperature = 0.7,
    this.topP = 0.9,
    this.topK = 40,
    this.repetitionPenalty = 1.1,
    this.maxTokens = 4096,
    this.stopSequences = const [],
    this.seed,
  });

  GenerationParams copyWith({
    double? temperature, double? topP, int? topK,
    double? repetitionPenalty, int? maxTokens,
    List<String>? stopSequences, int? seed,
  }) => GenerationParams(
    temperature: temperature ?? this.temperature,
    topP: topP ?? this.topP,
    topK: topK ?? this.topK,
    repetitionPenalty: repetitionPenalty ?? this.repetitionPenalty,
    maxTokens: maxTokens ?? this.maxTokens,
    stopSequences: stopSequences ?? this.stopSequences,
    seed: seed,
  );

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'top_p': topP,
        'top_k': topK,
        'repetition_penalty': repetitionPenalty,
        'max_tokens': maxTokens,
        'stop': stopSequences,
        if (seed != null) 'seed': seed,
      };
}
