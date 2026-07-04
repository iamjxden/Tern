import '../tool.dart';

class WebSearchTool extends Tool {
  @override
  String get name => 'web_search';

  @override
  String get description =>
      'Search the web for current information, returning titles, URLs, and content snippets. '
      'Use when you need facts, recent events, or information beyond your knowledge cutoff.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'The search query. Be specific for better results.',
          },
          'num_results': {
            'type': 'integer',
            'description': 'Number of results to return (1-10).',
          },
        },
        'required': ['query'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final query = args['query'] as String;
    final numResults = (args['num_results'] as int?)?.clamp(1, 10) ?? 5;
    final results = [
      '1. Result for "$query" — https://example.com/1',
      '2. Secondary result — https://example.com/2',
      '3. Additional context — https://example.com/3',
    ].take(numResults).join('\n');
    return 'Search: "$query"\n\n$results\n\n'
        'Results are placeholder. Enable network in Settings for live search.';
  }
}
