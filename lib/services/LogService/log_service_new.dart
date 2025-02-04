import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_demo/constants/app_strings.dart';
import 'package:flutter_demo/constants/base_url_config.dart';
import 'package:flutter_demo/services/EncryptionService/encryption_service_new.dart';
import 'package:flutter_demo/services/EncryptionService/file_encryption_cbc.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LogServiceNew {
  static String? _deviceId; // Cached Device ID
  static String? _logFilePath; // Cached log file path
  static String? _fileName;
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

        if (kDebugMode) {
          log(androidInfo.model);
          log(androidInfo.product);
          log(androidInfo.device);
        }
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
    DateTime date = DateTime.now();
    List vals = [
      date.day<10?"0${date.day}": date.day,
      date.month<10?"0${date.month}": date.month,
      date.year
    ];
    String today = "${vals[0]}_${vals[1]}_${vals[2]}";

    // Generate log file name with device ID and timestamp
    _fileName = '${_deviceId}_$today.log';

    // Get the app documents directory
    final Directory directory = await getApplicationDocumentsDirectory();
    _logFilePath = '${directory.path}/$_fileName';

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

      if (stackTrace!.isNotEmpty) {
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

  static Future<void> sendLogFile({String logEntry = ''}) async {
    try {
      await _initializeDeviceInfo();

      final logFile = await _getLogFile();
      String encryptionKey =
          kDebugMode ? AppStrings.encryptDebug : AppStrings.encryptkeyProd;

      final fileEncryptionResult =
          await FileEncryptionService.encryptFile(logFile, encryptionKey);

      if (fileEncryptionResult.isEmpty ||
          !fileEncryptionResult.containsKey("encryptedFile") ||
          !fileEncryptionResult.containsKey("iv") ||
          fileEncryptionResult['iv'].toString().trim().isEmpty ||
          fileEncryptionResult['encryptedFile'] is! File) {
        if (kDebugMode) {
          log("could not encrypt log file");
        }
        return;
      }

      final String? encryptedMetadata =
          encryptMetadata(encryptionKey, fileEncryptionResult['iv']);
      if (kDebugMode) {
        print(encryptedMetadata);
      }

      if (encryptedMetadata!.isEmpty) {
        if (kDebugMode) {
          print("Could not create encrypted metadata for logfile");
        }
        return;
      }

      final uri =
          Uri.parse('${BaseUrlConfig.baseUrlDemoDevelopment}/logs/upload-log');

      if (kDebugMode) {
        log("url is $uri");
      }

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', fileEncryptionResult['encryptedFile'].path))
        ..fields['json'] =
            encryptedMetadata; // Sending encrypted metadata as a form field

      final response = await request.send();

      if (kDebugMode) {
        print("log file upload response");
        print(response.statusCode);
        // log(response.body);
      }

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

  static String? encryptMetadata(
      String encryptionKey, String initializationVector) {
    try {
      // Generate metadata and encrypt it
      final metadata = {
        'deviceId': _deviceId,
        'deviceModel': _deviceModel,
        'osSystemVersion': _osVersion, // Add this
        'platform': Platform.operatingSystem, // Add this,
        "iv": initializationVector,
        "fileName": _fileName
      };

      if(kDebugMode){
        print("meta data ");
        print(metadata);
      }

      final serializedMetadataString = jsonEncode(metadata);

      String encryptedSerializedMetadataString =
          AESUtil().encryptDataV2(serializedMetadataString, encryptionKey);

      return encryptedSerializedMetadataString;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Encrypting device metadata to send along with log file error");
        print(e);
        print(stackTrace);
      }
      return null;
    }
  }

}
