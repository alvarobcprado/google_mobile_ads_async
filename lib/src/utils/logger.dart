import 'package:logger/logger.dart';

/// A centralized logging service for the package.
///
/// This class is a singleton that wraps the `logger` package to provide
/// a consistent logging format and a single point of control for the log level.
class AdLogger {
  // Private constructor for the singleton
  AdLogger._();

  /// The static instance of the logger.
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
    ),
  );

  /// Sets the desired log level for the entire package.
  ///
  /// Defaults to `Level.off`.
  // ignore: use_setters_to_change_properties
  static void setLevel(Level level) {
    Logger.level = level;
  }

  // Log methods that will be used throughout the package
  /// Logs a message at level [Level.trace].
  static void verbose(dynamic message) => _logger.t(message);

  /// Logs a message at level [Level.debug].
  static void debug(dynamic message) => _logger.d(message);

  /// Logs a message at level [Level.info].
  static void info(dynamic message) => _logger.i(message);

  /// Logs a message at level [Level.warning].
  static void warning(dynamic message) => _logger.w(message);

  /// Logs a message at level [Level.error].
  static void error(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
