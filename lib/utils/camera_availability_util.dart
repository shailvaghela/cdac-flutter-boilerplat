import 'dart:html' as html;

class CheckCameraAvailability {
  // Static method to check if a device is available
  static Future<bool> checkDeviceAvailability(String deviceKind) async {
    try {
      final devices = await html.window.navigator.mediaDevices?.enumerateDevices();
      bool deviceFound = false;

      for (var device in devices ?? []) {
        if (device.kind == deviceKind) {
          deviceFound = true;
          break;
        }
      }
      return deviceFound;
    } catch (e) {
      return false;
    }
  }
}


/*
Future<void> checkCameraAvailability() async {
  bool cameraFound = await DeviceUtils.checkDeviceAvailability('videoinput');
  setState(() {
    isCameraAvailable = cameraFound;
  });
}*/
