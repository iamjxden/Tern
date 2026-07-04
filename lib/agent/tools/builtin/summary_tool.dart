import '../tool.dart';

class SummaryTool extends Tool {
  @override
  String get name => 'summary';

  @override
  String get description =>
      'Summarize a long text into a concise version while preserving key information. '
      'Useful for condensing large outputs or documents.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'text': {'type': 'string', 'description': 'The text to summarize.'},
          'max_sentences': {
            'type': 'integer',
            'description': 'Maximum number of sentences in the summary (default: 5).',
          },
        },
        'required': ['text'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final text = args['text'] as String;
    final maxSentences = args['max_sentences'] as int? ?? 5;
    if (text.length <= 200) return 'Text too short to summarize:\n\n$text';
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .take(maxSentences)
        .join(' ');
    return '[Summary of ${text.length} chars → ${sentences.length} chars]\n\n$sentences...';
  }
}
