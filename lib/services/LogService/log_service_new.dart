import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_demo/constants/app_strings.dart';
import 'package:flutter_demo/constants/base_url_config.dart';
import 'package:flutter_demo/services/EncryptionService/encryption_service_new.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LogServiceNew {
  static String? _deviceId; // Cached Device ID
  static String? _logFilePath; // Cached log file path
  static String? _deviceModel; // Cached device model (e.g., Pixel 5)
  static String? _osVersion; // Cached OS version

  /// Fetch and cache device ID, model, and OS version
  static Future<void> _initializeDeviceInfo() async {
    if (_deviceId == null || _deviceModel == null || _osVersion == null) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
        _deviceModel = androidInfo.model;
        _osVersion = androidInfo.version.release; // Example: "13.0"
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
        _deviceModel = iosInfo.modelName; // Example: "iPhone 13 Pro"
        _osVersion = iosInfo.systemVersion; // Example: "17.2"
      }
    }
  }

  /// Get or create the log file with the correct naming convention
  static Future<File> _getLogFile() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw Exception("Logging is only supported on Android and iOS");
    }

    await _initializeDeviceInfo();
    if (_deviceId == null || _deviceModel == null || _osVersion == null) {
      throw Exception("Failed to retrieve device information");
    }

    // Generate log file name with device ID and timestamp
    String fileName =
        '${_deviceId}_${DateTime.now().millisecondsSinceEpoch}.log';

    // Get the app documents directory
    final Directory directory = await getApplicationDocumentsDirectory();
    _logFilePath = '${directory.path}/$fileName';

    File logFile = File(_logFilePath!);

    if (!(await logFile.exists())) {
      await logFile.create();
      if (kDebugMode) {
        print("✅ Log file created: $_logFilePath");
      }
    } else {
      if (kDebugMode) {
        print("📂 Log file already exists: $_logFilePath");
      }
    }

    return logFile;
  }

  /// Append a log entry to the log file
  static Future<void> logToFile(
      {required String message,
      required String screenName,
      required String methodName,
      Level level = Level.info,
      String? stackTrace = ''}) async {
    try {
      // Log entry format: <dateTime> - <deviceId> - <deviceModel>_<osVersion> - <screenName> - <methodName> - <level> - <message>
      String logEntry =
          '${DateTime.now()} - $_deviceId - $_deviceModel - $_osVersion - $screenName - $methodName - - ${level.toString().toUpperCase()} - $message\n';

      if(stackTrace!.isNotEmpty){
        logEntry = "$logEntry $stackTrace";
      }

      File logFile = await _getLogFile();

      // Write to file
      await logFile.writeAsString(logEntry, mode: FileMode.append);

      if (kDebugMode) {
        print("📝 Log Entry Written:\n$logEntry");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to write log: $e");
      }
    }
  }

  static Future<void> sendLogFile(String logEntry) async {
    try {
      await _initializeDeviceInfo();

      final logFile = await _getLogFile();
      final String encryptedMetadata = encryptMetadata();
      if (kDebugMode) {
        print(encryptedMetadata);
      }

      final uri = Uri.parse(
          '${BaseUrlConfig.baseUrlDemoDevelopment}/user-interface-log/upload-log');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('logFile', logFile.path))
        ..fields['json'] =
            encryptedMetadata; // Sending encrypted metadata as a form field

      final response = await request.send();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('File uploaded successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload file');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading file: $e");
      }
    }
  }

  static String encryptMetadata() {
    // Generate metadata and encrypt it
    final metadata = {
      'deviceId': _deviceId,
      'deviceModel': _deviceModel,
      'osVersion': _osVersion,
    };

    final serializedMetadataString = jsonEncode(metadata);

    String encryptionKey =
        kDebugMode ? AppStrings.encryptDebug : AppStrings.encryptkeyProd;

    String encryptedSerializedMetadataString =
        AESUtil().encryptDataV2(serializedMetadataString, encryptionKey);

    return encryptedSerializedMetadataString;
  }
}
