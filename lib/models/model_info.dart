enum ModelRole { text, vision, speech }

enum ModelCategory { general, coding, vision, speech }

class ModelInfo {
  final String id;
  final String displayName;
  final String tagline;
  final ModelCategory category;
  final ModelRole role;
  final double sizeGb;
  final int contextWindow;
  final List<String> effortLevels;
  final bool isDefault;
  final bool cloud;
  final bool autoSwitch;

  const ModelInfo({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.category,
    required this.role,
    required this.sizeGb,
    required this.contextWindow,
    this.effortLevels = const ['standard'],
    this.isDefault = false,
    this.cloud = false,
    this.autoSwitch = false,
  });

  String get sizeLabel => cloud ? 'Cloud' : '${sizeGb.toStringAsFixed(1)} GB';

  String get contextLabel {
    if (contextWindow >= 1000000) return '${(contextWindow / 1000000).toStringAsFixed(1)}M context';
    return '${(contextWindow / 1000).round()}K context';
  }

  static ModelCategory _categoryFromString(String value) {
    switch (value) {
      case 'coding':
        return ModelCategory.coding;
      case 'vision':
        return ModelCategory.vision;
      case 'speech':
        return ModelCategory.speech;
      default:
        return ModelCategory.general;
    }
  }

  static ModelRole _roleFromString(String value) {
    switch (value) {
      case 'vision':
        return ModelRole.vision;
      case 'speech':
        return ModelRole.speech;
      default:
        return ModelRole.text;
    }
  }

  factory ModelInfo.fromJson(Map<String, dynamic> json) => ModelInfo(
        id: json['id'] as String,
        displayName: json['display_name'] as String? ?? json['id'] as String,
        tagline: json['tagline'] as String? ?? '',
        category: _categoryFromString(json['category'] as String? ?? 'general'),
        role: _roleFromString(json['role'] as String? ?? 'text'),
        sizeGb: (json['size_gb'] as num?)?.toDouble() ?? 0,
        contextWindow: json['context_window'] as int? ?? 8192,
        effortLevels: (json['effort_levels'] as List?)?.cast<String>() ?? const ['standard'],
        isDefault: json['is_default'] as bool? ?? false,
        cloud: json['cloud'] as bool? ?? false,
        autoSwitch: json['auto_switch'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'tagline': tagline,
        'category': category.name,
        'role': role.name,
        'size_gb': sizeGb,
        'context_window': contextWindow,
        'effort_levels': effortLevels,
        'is_default': isDefault,
        'cloud': cloud,
        'auto_switch': autoSwitch,
      };
}
