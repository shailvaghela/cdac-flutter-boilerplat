import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
class DeviceUtils {
  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  static Future<dynamic> getDeviceInfo() async {
    if (Platform.isAndroid) {
      return await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      return await deviceInfo.iosInfo;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}