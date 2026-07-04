import 'package:logging/logging.dart';
import '../../config/environment.dart';

class HumanNodeLogger {
  static final Logger _logger = Logger('Tern');
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    Logger.root.level = Env.verboseLogging ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen(_handleRecord);
    _initialized = true;
  }

  static void _handleRecord(LogRecord record) {
    final timestamp = record.time.toIso8601String().substring(11, 23);
    final level = record.level.name.padRight(5).toUpperCase();
    final name = record.loggerName.padRight(10);
    final msg = record.message;
    final line = '[$timestamp] $level $name $msg';
    if (record.level >= Level.SEVERE && record.error != null) {
      final errorLine = '$line | Error: ${record.error}';
      if (record.stackTrace != null) {
        final st = record.stackTrace.toString().split('\n').take(5).join('\n  ');
        print('$errorLine\n  $st');
      } else {
        print(errorLine);
      }
    } else {
      print(line);
    }
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.fine(message);
  static void info(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.info(message);
  static void warn(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.warning(message);
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.severe(message, error, stackTrace);
  static void fatal(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.shout(message, error, stackTrace);
}
