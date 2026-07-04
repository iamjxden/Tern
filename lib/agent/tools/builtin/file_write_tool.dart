import 'dart:io';
import '../tool.dart';

class FileWriteTool extends Tool {
  @override
  String get name => 'file_write';

  @override
  String get description =>
      'Write content to a file in the application sandbox. '
      'Creates parent directories as needed. Overwrites existing files.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'path': {'type': 'string', 'description': 'Relative path for the new file.'},
          'content': {'type': 'string', 'description': 'The text content to write.'},
          'mode': {
            'type': 'string',
            'enum': ['overwrite', 'append'],
            'description': 'Write mode: overwrite (default) or append.',
          },
        },
        'required': ['path', 'content'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final path = args['path'] as String;
    final content = args['content'] as String;
    final mode = args['mode'] as String? ?? 'overwrite';
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      if (mode == 'append' && await file.exists()) {
        await file.writeAsString(content, mode: FileMode.append);
        return 'Appended ${content.length} chars to $path';
      }
      await file.writeAsString(content);
      return 'Wrote ${content.length} chars to $path';
    } catch (e) {
      return 'Error writing file: $e';
    }
  }
}
