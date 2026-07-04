import 'dart:async';
import 'dart:io';
import '../tool.dart';

class BashTool extends Tool {
  @override
  String get name => 'bash';

  @override
  String get description =>
      'Execute a bash command in a sandboxed environment. '
      'Output is limited to 8000 characters. Use for file operations, text processing, or system queries.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'command': {
            'type': 'string',
            'description': 'The bash command to execute.',
          },
          'timeout': {
            'type': 'integer',
            'description': 'Command timeout in seconds (default: 30).',
          },
        },
        'required': ['command'],
      };

  static const int _maxOutput = 8000;

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final command = args['command'] as String;
    final timeoutSeconds = args['timeout'] as int? ?? 30;
    try {
      final result = await Process.run(
        'bash',
        ['-c', command],
        runInShell: true,
      ).timeout(Duration(seconds: timeoutSeconds));
      final out = result.stdout.toString();
      final err = result.stderr.toString();
      final buffer = StringBuffer();
      if (out.isNotEmpty) {
        buffer.write(out.length > _maxOutput
            ? '${out.substring(0, _maxOutput)}\n[truncated]'
            : out);
      }
      if (err.isNotEmpty) {
        buffer.write(
            '\n[stderr]\n${err.length > 1000 ? '${err.substring(0, 1000)}\n[truncated]' : err}');
      }
      if (buffer.isEmpty) buffer.write('(no output)');
      buffer.write('\n[exit: ${result.exitCode}]');
      return buffer.toString();
    } on TimeoutException {
      return 'Command timed out after $timeoutSeconds seconds';
    } catch (e) {
      return 'Command execution failed: $e';
    }
  }
}
