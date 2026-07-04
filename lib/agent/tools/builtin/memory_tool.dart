import '../tool.dart';

class MemoryTool extends Tool {
  final Map<String, String> _store = {};

  @override
  String get name => 'memory';

  @override
  String get description =>
      'Persistent key-value memory store. Use "store" to save information, '
      '"recall" to retrieve it, "list" to see all keys, and "delete" to remove. '
      'Memories persist for the duration of the session.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'action': {
            'type': 'string',
            'enum': ['store', 'recall', 'list', 'delete'],
            'description': 'The memory operation to perform.',
          },
          'key': {'type': 'string', 'description': 'Memory key (for store, recall, delete).'},
          'value': {'type': 'string', 'description': 'Value to store (for store action only).'},
        },
        'required': ['action'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final action = args['action'] as String;
    return switch (action) {
      'store' => _doStore(args['key'] as String?, args['value'] as String?),
      'recall' => _doRecall(args['key'] as String?),
      'list' => _doList(),
      'delete' => _doDelete(args['key'] as String?),
      _ => 'Unknown action: $action. Use store, recall, list, or delete.',
    };
  }

  String _doStore(String? key, String? value) {
    if (key == null || key.isEmpty) return 'Missing required parameter: key';
    if (value == null || value.isEmpty) return 'Missing required parameter: value';
    _store[key] = value;
    return 'Stored "$key" → "${value.length > 50 ? '${value.substring(0, 50)}...' : value}"';
  }

  String _doRecall(String? key) {
    if (key == null || key.isEmpty) return 'Missing required parameter: key';
    final value = _store[key];
    return value != null ? '"$key" → $value' : 'No memory found for key: "$key"';
  }

  String _doList() {
    if (_store.isEmpty) return 'Memory is empty. Use store to add entries.';
    return 'Memory keys (${_store.length}):\n${_store.keys.map((k) => '  - $k').join('\n')}';
  }

  String _doDelete(String? key) {
    if (key == null || key.isEmpty) return 'Missing required parameter: key';
    final removed = _store.remove(key);
    return removed != null ? 'Deleted memory: "$key"' : 'No memory found for key: "$key"';
  }
}
