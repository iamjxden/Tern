import 'package:uuid/uuid.dart';
import 'package:tern/core/di/service_locator.dart';
import '../tool.dart';

class NoteCreateTool extends Tool {
  @override
  String get name => 'note_create';

  @override
  String get description =>
      'Create a new note with a title and content. Notes persist across sessions.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'title': {'type': 'string', 'description': 'Note title (required).'},
          'content': {'type': 'string', 'description': 'Note content body.'},
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'Optional tags for categorization.',
          },
        },
        'required': ['title', 'content'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final title = args['title'] as String;
    final content = args['content'] as String;
    final tags = args['tags'] as List<dynamic>?;
    final id = const Uuid().v4();
    await ServiceLocator.noteDao.insert(id, title, content);
    final tagStr = tags != null && tags.isNotEmpty ? ' [${tags.join(', ')}]' : '';
    return 'Note created: "$title"$tagStr (id: $id). ${content.length} characters saved.';
  }
}
