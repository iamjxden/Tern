// TernLogger — re-export of HumanNodeLogger under the Tern name.
// Both names are supported during the migration so nothing breaks.
export 'humannode_logger.dart' show HumanNodeLogger;

/// Alias so new files can import TernLogger without breaking old ones.
class TernLogger {
  static void init() => HumanNodeLogger.init();
  static void debug(String m, [Object? e, StackTrace? s]) => HumanNodeLogger.debug(m, e, s);
  static void info(String m, [Object? e, StackTrace? s]) => HumanNodeLogger.info(m, e, s);
  static void warn(String m, [Object? e, StackTrace? s]) => HumanNodeLogger.warn(m, e, s);
  static void error(String m, [Object? e, StackTrace? s]) => HumanNodeLogger.error(m, e, s);
  static void fatal(String m, [Object? e, StackTrace? s]) => HumanNodeLogger.fatal(m, e, s);
}
