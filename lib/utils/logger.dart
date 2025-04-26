import 'package:logging/logging.dart' show Level, Logger;

/// Application logger utility to provide consistent logging throughout the app
class AppLogger {
  static final Map<String, Logger> _loggers = {};

  /// Initialize the logger configuration, call this in main.dart
  static void init() {
    Logger.root.level = Level.ALL; // Set desired level
    Logger.root.onRecord.listen((record) {
      // Use environment-aware logging approach
      _logOutput('${record.level.name}: ${record.time}: ${record.message}');
      
      if (record.error != null) {
        _logOutput('Error: ${record.error}');
      }
      
      if (record.stackTrace != null) {
        _logOutput('Stack trace:\n${record.stackTrace}');
      }
    });
  }

  /// Routes log messages to appropriate output based on environment
  static void _logOutput(String message) {
    // Debug mode only - will be stripped in release builds
    assert(() {
      print(message); // Only used in debug mode
      return true;
    }());
    
    // For production, implement appropriate logging
    // TODO: Implement production logging (file, service, etc.)
  }

  /// Get a logger instance for a specific class or module
  static Logger getLogger(String name) {
    if (!_loggers.containsKey(name)) {
      _loggers[name] = Logger(name);
    }
    return _loggers[name]!;
  }
}
