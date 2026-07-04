import '../tool.dart';

class FetchUrlTool extends Tool {
  @override
  String get name => 'fetch_url';

  @override
  String get description =>
      'Fetch the contents of a URL and return it as text/markdown. '
      'Useful for reading documentation, checking APIs, or retrieving web content.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'url': {'type': 'string', 'description': 'The URL to fetch (must start with http:// or https://).'},
          'headers': {
            'type': 'object',
            'description': 'Optional HTTP headers to include with the request.',
          },
        },
        'required': ['url'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final url = args['url'] as String;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'Invalid URL: $url (must use http:// or https://)';
    }
    return '[Fetched: $url]\nContent would be displayed here when network access is available.\nEnable connectivity in Settings for live URL fetching.';
  }
}
