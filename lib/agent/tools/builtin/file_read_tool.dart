import 'dart:io';
import '../tool.dart';

class FileReadTool extends Tool {
  @override
  String get name => 'file_read';

  @override
  String get description =>
      'Read the contents of a file from the application sandbox. '
      'Returns the text content with optional offset and limit for large files.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'path': {'type': 'string', 'description': 'Relative path to the file to read.'},
          'offset': {'type': 'integer', 'description': 'Line number to start reading from.'},
          'limit': {'type': 'integer', 'description': 'Maximum number of lines to return.'},
        },
        'required': ['path'],
      };

  static const int _maxSize = 50 * 1024;

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final path = args['path'] as String;
    final offset = args['offset'] as int?;
    final limit = args['limit'] as int?;
    try {
      final file = File(path);
      if (!await file.exists()) return 'File not found: $path';
      final stat = await file.stat();
      if (stat.size > _maxSize && offset == null && limit == null) {
        return 'File too large to read at once (${stat.size} bytes). Use offset and limit.';
      }
      final contents = await file.readAsString();
      if (offset != null || limit != null) {
        final lines = contents.split('\n');
        final start = offset ?? 0;
        final end = limit != null ? start + limit : lines.length;
        return 'Lines $start-${end > lines.length ? lines.length : end} of $path:\n'
            '${lines.sublist(start, end.clamp(0, lines.length)).join('\n')}';
      }
      if (contents.length > 10000) {
        return '${contents.substring(0, 10000)}\n\n[Truncated at 10,000 chars. Total: ${contents.length}]';
      }
      return contents;
    } catch (e) {
      return 'Error reading file: $e';
    }
  }
}
