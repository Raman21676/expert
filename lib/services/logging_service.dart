import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Logging Service
/// 
/// Local logging for debugging offline AI behavior.
/// Essential since we don't have a cloud dashboard.
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static LoggingService get instance => _instance;

  File? _logFile;
  bool _initialized = false;
  final List<LogEntry> _recentLogs = [];
  static const int _maxRecentLogs = 100;

  /// Initialize the logging service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(appDir.path, 'logs'));
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File(path.join(logDir.path, 'lingo_native_$timestamp.log'));
      
      // Write header
      await _logFile!.writeAsString(
        '=== LingoNative AI Log ===\n'
        'Started: ${DateTime.now().toIso8601String()}\n'
        '========================\n\n',
        mode: FileMode.append,
      );

      _initialized = true;
      log(LogLevel.info, 'LoggingService', 'Logging initialized');
    } catch (e) {
      print('Failed to initialize logging: $e');
    }
  }

  /// Log a message
  void log(
    LogLevel level,
    String component,
    String message, {
    Map<String, dynamic>? metadata,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      component: component,
      message: message,
      metadata: metadata,
    );

    // Add to recent logs
    _recentLogs.add(entry);
    if (_recentLogs.length > _maxRecentLogs) {
      _recentLogs.removeAt(0);
    }

    // Write to file
    _writeToFile(entry);

    // Print to console in debug mode
    _printToConsole(entry);
  }

  /// Convenience methods
  void debug(String component, String message, {Map<String, dynamic>? metadata}) {
    log(LogLevel.debug, component, message, metadata: metadata);
  }

  void info(String component, String message, {Map<String, dynamic>? metadata}) {
    log(LogLevel.info, component, message, metadata: metadata);
  }

  void warning(String component, String message, {Map<String, dynamic>? metadata}) {
    log(LogLevel.warning, component, message, metadata: metadata);
  }

  void error(String component, String message, {Map<String, dynamic>? metadata, Object? error, StackTrace? stackTrace}) {
    final meta = <String, dynamic>{
      if (metadata != null) ...metadata,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
    log(LogLevel.error, component, message, metadata: meta.isNotEmpty ? meta : null);
  }

  /// Log LLM interaction (critical for debugging AI behavior)
  void logLLMInteraction({
    required String prompt,
    required String response,
    required int durationMs,
    required bool success,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    final meta = <String, dynamic>{
      'prompt_length': prompt.length,
      'response_length': response.length,
      'duration_ms': durationMs,
      'success': success,
      if (error != null) 'error': error,
      if (metadata != null) ...metadata,
    };

    final level = success ? LogLevel.info : LogLevel.error;
    final message = success
        ? 'LLM request completed in ${durationMs}ms'
        : 'LLM request failed: $error';

    log(level, 'LLM', message, metadata: meta);

    // Also log full prompt/response in debug mode
    debug('LLM', 'Full prompt:\n$prompt');
    debug('LLM', 'Full response:\n$response');
  }

  /// Log user action for analytics
  void logUserAction(String action, {Map<String, dynamic>? metadata}) {
    log(LogLevel.info, 'UserAction', action, metadata: metadata);
  }

  /// Write entry to file
  Future<void> _writeToFile(LogEntry entry) async {
    if (_logFile == null) return;

    try {
      final line = entry.toString() + '\n';
      await _logFile!.writeAsString(line, mode: FileMode.append, flush: false);
    } catch (e) {
      print('Failed to write log: $e');
    }
  }

  /// Print to console
  void _printToConsole(LogEntry entry) {
    final emoji = entry.level.emoji;
    final time = entry.timestamp.toIso8601String().substring(11, 19);
    print('[$time] $emoji [${entry.component}] ${entry.message}');
  }

  /// Get recent logs
  List<LogEntry> getRecentLogs({int limit = 50, LogLevel? minLevel}) {
    var logs = _recentLogs;
    
    if (minLevel != null) {
      logs = logs.where((l) => l.level.index >= minLevel.index).toList();
    }
    
    if (logs.length > limit) {
      return logs.sublist(logs.length - limit);
    }
    return List.unmodifiable(logs);
  }

  /// Export logs to string (for sharing/debugging)
  Future<String> exportLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No logs available';
    }

    try {
      return await _logFile!.readAsString();
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  /// Get log file path
  Future<String?> getLogFilePath() async {
    return _logFile?.path;
  }

  /// Clear old logs (keep only last N days)
  Future<void> cleanupOldLogs({int keepDays = 7}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(appDir.path, 'logs'));
      
      if (!await logDir.exists()) return;

      final cutoff = DateTime.now().subtract(Duration(days: keepDays));
      final files = await logDir.list().toList();

      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoff)) {
            await file.delete();
          }
        }
      }

      info('LoggingService', 'Cleaned up old logs');
    } catch (e) {
      error('LoggingService', 'Failed to cleanup logs', error: e);
    }
  }

  /// Get log statistics
  Map<String, dynamic> getStats() {
    final stats = <String, int>{};
    
    for (final log in _recentLogs) {
      stats[log.level.name] = (stats[log.level.name] ?? 0) + 1;
    }

    return {
      'total_logs': _recentLogs.length,
      'by_level': stats,
      'log_file': _logFile?.path,
    };
  }
}

// ============================================================================
// DATA CLASSES
// ============================================================================

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

extension LogLevelExtension on LogLevel {
  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String get emoji {
    switch (this) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String component;
  final String message;
  final Map<String, dynamic>? metadata;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.component,
    required this.message,
    this.metadata,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name}] ');
    buffer.write('[$component] ');
    buffer.write(message);
    
    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(metadata!.entries.map((e) => '${e.key}=${e.value}').join(', '));
    }
    
    return buffer.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'component': component,
      'message': message,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
