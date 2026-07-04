class ModelPreset {
  final String id;
  final String name;
  final String modelId;
  final double temperature;
  final double topP;
  final int topK;
  final double repetitionPenalty;
  final int maxTokens;
  final String systemPrompt;
  final bool isDefault;

  const ModelPreset({
    required this.id,
    required this.name,
    required this.modelId,
    this.temperature = 0.7,
    this.topP = 0.9,
    this.topK = 40,
    this.repetitionPenalty = 1.1,
    this.maxTokens = 4096,
    this.systemPrompt = '',
    this.isDefault = false,
  });

  factory ModelPreset.defaultPreset() => const ModelPreset(
        id: 'default',
        name: 'Default',
        modelId: '',
        isDefault: true,
      );

  factory ModelPreset.coding() => const ModelPreset(
        id: 'coding',
        name: 'Coding',
        modelId: '',
        temperature: 0.3,
        topP: 0.95,
        isDefault: false,
      );

  factory ModelPreset.creative() => const ModelPreset(
        id: 'creative',
        name: 'Creative',
        modelId: '',
        temperature: 1.0,
        topP: 0.95,
        topK: 60,
        isDefault: false,
      );

  ModelPreset copyWith({
    String? name, String? modelId, double? temperature,
    double? topP, int? topK, double? repetitionPenalty,
    int? maxTokens, String? systemPrompt,
  }) => ModelPreset(
    id: id,
    name: name ?? this.name,
    modelId: modelId ?? this.modelId,
    temperature: temperature ?? this.temperature,
    topP: topP ?? this.topP,
    topK: topK ?? this.topK,
    repetitionPenalty: repetitionPenalty ?? this.repetitionPenalty,
    maxTokens: maxTokens ?? this.maxTokens,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    isDefault: isDefault,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'model_id': modelId,
        'temperature': temperature,
        'top_p': topP,
        'top_k': topK,
        'repetition_penalty': repetitionPenalty,
        'max_tokens': maxTokens,
        'system_prompt': systemPrompt,
        'is_default': isDefault,
      };

  factory ModelPreset.fromJson(Map<String, dynamic> json) => ModelPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        modelId: json['model_id'] as String? ?? '',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
        topP: (json['top_p'] as num?)?.toDouble() ?? 0.9,
        topK: json['top_k'] as int? ?? 40,
        repetitionPenalty: (json['repetition_penalty'] as num?)?.toDouble() ?? 1.1,
        maxTokens: json['max_tokens'] as int? ?? 4096,
        systemPrompt: json['system_prompt'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );
}
