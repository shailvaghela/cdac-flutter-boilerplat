import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LogService {
  static int _logPoint = 0; // Counter for log points

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      // Number of stack trace lines
      errorMethodCount: 8,
      // Number of stack trace lines for errors
      lineLength: 100,
      // Log line length
      colors: true,
      // Enable colors in debug mode
      printEmojis: true,
      // Print emojis
      printTime: true, // Print timestamps
    ),
  );

  static Future<File> _getLogFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File logFile = File('${directory.path}/app_logs.txt');

    if (!(await logFile.exists())) {
      await logFile.create();
    }
    return logFile;
  }

  /// Logs a message and saves it to a file
  static Future<void> logToFile(String message,
      {Level level = Level.info}) async {
    try {
      // Increment the log point for each log entry
      _logPoint++;

      File logFile = await _getLogFile();
      String logEntry =
          '${DateTime.now()} - Point $_logPoint - ${level.name.toUpperCase()} - $message\n';

      // Write log entry to the file
      await logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      debugPrint("Failed to write log: $e");
    }
  }

  /// Logging methods
  static void debug(String message) {
    _logger.d(message);
    logToFile(message, level: Level.debug);
  }

  static void info(String message) {
    _logger.i(message);
    logToFile(message, level: Level.info);
  }

  static void warning(String message) {
    _logger.w(message);
    logToFile(message, level: Level.warning);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    logToFile("$message - $error", level: Level.error);
    // Upload logs if an error occurs
    //uploadLogFile();
  }

  /// Get log file path (for debugging)
  static Future<String> getLogFilePath() async {
    File logFile = await _getLogFile();
    return logFile.path;
  }

  static Future<String> readLogs() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File logFile = File('${appDocDir.path}/app_logs.txt');

    if (await logFile.exists()) {
      return await logFile.readAsString();
    }
    return "No logs found.";
  }

  /// Uploads log file to the server
  static Future<void> uploadLogFile() async {
    try {
      File logFile = await _getLogFile();
      if (!(await logFile.exists())) {
        debugPrint("Log file does not exist.");
        return;
      }

      // API endpoint
      String url = "https://yourserver.com/upload";

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files
          .add(await http.MultipartFile.fromPath('file', logFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        debugPrint("Log file uploaded successfully.");
      } else {
        debugPrint("Failed to upload log file: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error uploading log file: $e");
    }
  }
}
