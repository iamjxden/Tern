abstract class Tool {
  String get name;
  String get description;
  Map<String, dynamic> get parametersJsonSchema;

  Future<String> execute(Map<String, dynamic> args);

  bool validateArgs(Map<String, dynamic> args) {
    final properties = parametersJsonSchema['properties'] as Map<String, dynamic>?;
    final required = (parametersJsonSchema['required'] as List<dynamic>? ?? [])
        .cast<String>();
    if (properties == null) return true;
    for (final key in required) {
      if (!args.containsKey(key)) return false;
    }
    for (final entry in args.entries) {
      if (!properties.containsKey(entry.key)) return false;
      final prop = properties[entry.key] as Map<String, dynamic>?;
      if (prop == null) continue;
      final type = prop['type'] as String?;
      if (type == 'string' && entry.value is! String) return false;
      if (type == 'number' && entry.value is! num) return false;
      if (type == 'integer' && entry.value is! int) return false;
      if (type == 'boolean' && entry.value is! bool) return false;
      if (type == 'array' && entry.value is! List) return false;
      if (type == 'object' && entry.value is! Map) return false;
      final enumValues = prop['enum'] as List<dynamic>?;
      if (enumValues != null && !enumValues.contains(entry.value)) return false;
    }
    return true;
  }

  String get schemaXml {
    final buffer = StringBuffer();
    buffer.writeln('  <tool>');
    buffer.writeln('    <name>$name</name>');
    buffer.writeln('    <description>$description</description>');
    final props = parametersJsonSchema['properties'] as Map<String, dynamic>?;
    final required = (parametersJsonSchema['required'] as List<dynamic>? ?? []);
    if (props != null) {
      buffer.writeln('    <parameters>');
      for (final entry in props.entries) {
        final prop = entry.value as Map<String, dynamic>;
        final type = prop['type'] ?? 'string';
        final desc = prop['description'] ?? '';
        final req = required.contains(entry.key) ? ' (required)' : '';
        buffer.writeln('      <$entry.key type="$type"$req>$desc</$entry.key>');
      }
      buffer.writeln('    </parameters>');
    }
    buffer.writeln('  </tool>');
    return buffer.toString();
  }
}
