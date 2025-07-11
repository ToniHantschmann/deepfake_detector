import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class SimpleCrashLogger {
  static bool _initialized = false;
  static late Directory _logDirectory;

  /// Initialisiert den einfachen Crash Logger - nur einmal in main() aufrufen
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Setup log directory
      final appDocDir = await getApplicationDocumentsDirectory();
      _logDirectory = Directory('${appDocDir.path}/crash_logs');

      if (!await _logDirectory.exists()) {
        await _logDirectory.create(recursive: true);
      }

      // Setup global error handlers
      FlutterError.onError = (FlutterErrorDetails details) {
        _logCrash('Flutter Error', details.exception, details.stack);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _logCrash('Platform Error', error, stack);
        return true;
      };

      _initialized = true;
      await _logInfo('Crash Logger initialized');
    } catch (e) {
      debugPrint('Failed to initialize crash logger: $e');
    }
  }

  /// Loggt einen Crash in eine Datei
  static Future<void> _logCrash(
      String type, dynamic error, StackTrace? stackTrace) async {
    try {
      final timestamp = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
      final filename = 'crash_${formatter.format(timestamp)}.log';

      final crashInfo = {
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'error': error.toString(),
        'stackTrace': stackTrace?.toString() ?? 'No stack trace available',
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      };

      final logContent = '''
${'=' * 80}
DEEPFAKE DETECTOR CRASH LOG
${'=' * 80}
Time: ${timestamp.toIso8601String()}
Type: $type
ERROR:
${error.toString()}

STACK TRACE:
${stackTrace?.toString() ?? 'No stack trace available'}

JSON DATA:
${const JsonEncoder.withIndent('  ').convert(crashInfo)}
${'=' * 80}
''';

      final logFile = File('${_logDirectory.path}/$filename');
      await logFile.writeAsString(logContent);

      // Auch in die gemeinsame Log-Datei schreiben
      final mainLogFile = File('${_logDirectory.path}/all_crashes.log');
      await mainLogFile.writeAsString(
        '\n${'-' * 40}\n${timestamp.toIso8601String()} - $type\n${error.toString()}\n',
        mode: FileMode.append,
      );

      debugPrint('Crash logged to: ${logFile.path}');
    } catch (e) {
      debugPrint('Failed to log crash: $e');
    }
  }

  /// Loggt allgemeine Informationen
  static Future<void> _logInfo(String message) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logFile = File('${_logDirectory.path}/app.log');
      await logFile.writeAsString(
        '[$timestamp] INFO: $message\n',
        mode: FileMode.append,
      );
    } catch (e) {
      debugPrint('Failed to log info: $e');
    }
  }

  /// Gibt den Pfad zu den Log-Dateien zurück
  static String get logPath =>
      _initialized ? _logDirectory.path : 'Not initialized';
}
