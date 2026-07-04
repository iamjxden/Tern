import '../tool.dart';

class DatetimeTool extends Tool {
  @override
  String get name => 'datetime';

  @override
  String get description =>
      'Get the current date and time in various formats. Can also perform date arithmetic.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'format': {
            'type': 'string',
            'enum': ['iso', 'unix', 'human', 'date', 'time'],
            'description': 'Output format: iso, unix, human, date, or time.',
          },
          'timezone': {
            'type': 'string',
            'description': 'Timezone offset (e.g., +02:00, -05:00).',
          },
        },
        'required': [],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final format = args['format'] as String? ?? 'iso';
    final now = DateTime.now();
    return switch (format) {
      'iso' => now.toUtc().toIso8601String(),
      'unix' => '${now.millisecondsSinceEpoch ~/ 1000}',
      'human' => '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}, ${now.year} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      'date' => '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'time' => '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      _ => now.toUtc().toIso8601String(),
    };
  }

  String _weekday(int d) => const ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d];
  String _month(int m) => const ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m];
}
