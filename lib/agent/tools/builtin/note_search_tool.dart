import '../tool.dart';
import 'package:tern/core/di/service_locator.dart';

class NoteSearchTool extends Tool {
  @override
  String get name => 'note_search';

  @override
  String get description =>
      'Search through existing notes. Returns matching notes with relevance scores. '
      'Results are based on keyword matching.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'Search query.'},
          'limit': {
            'type': 'integer',
            'description': 'Maximum number of results (default: 5).'
          },
        },
        'required': ['query'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final query = args['query'] as String;
    final maxResults = args['limit'] as int? ?? 5;
    final notes = await ServiceLocator.noteDao.getAll();
    if (notes.isEmpty) {
      return 'No notes found. Create notes first using note_create.';
    }
    final lower = query.toLowerCase();
    final matches = notes.where((n) {
      final title = (n['title'] as String? ?? '').toLowerCase();
      final content = (n['content'] as String? ?? '').toLowerCase();
      return title.contains(lower) || content.contains(lower);
    }).take(maxResults).toList();

    if (matches.isEmpty) {
      return 'No notes matching "$query" found.';
    }
    final buffer = StringBuffer('Found ${matches.length} note(s) for "$query":\n\n');
    for (final note in matches) {
      buffer.writeln('Title: ${note['title']}');
      final content = note['content'] as String? ?? '';
      buffer.writeln(
          'Preview: ${content.length > 150 ? '${content.substring(0, 150)}...' : content}');
      buffer.writeln('Updated: ${note['updated_at']}');
      buffer.writeln();
    }
    return buffer.toString();
  }
}
