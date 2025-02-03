import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'device_id.dart';
class DirectoryUtils {
  static Future<String> saveImageToDirectory(File imageFile) async {
    try {
      // Get device ID
      String? deviceId = await DeviceId.getId();

      // Define directory path
      final Directory pathDir = Directory("storage/emulated/0/DCIM/ProfilePic");
      if (!(await pathDir.exists())) {
        await pathDir.create(recursive: true);
      }

      // Generate file name
      String username = "DummyUser"; // Replace with actual username
      String timestamp = DateFormat("ddMMyyyy_hhmmss").format(DateTime.now());
      String extension = imageFile.path.split('.').last;
      String newFileName = "${username}_${deviceId}_img_$timestamp.$extension";

      // Define new file path
      String newFilePath = "${pathDir.path}/$newFileName";

      if (kDebugMode) {
        print("Saving image to: $newFilePath");
      }

      // Copy the image to the new location
      File newFile = await imageFile.copy(newFilePath);

      return newFile.path; // Return the saved image path
    } catch (e) {
      throw Exception("Error saving image: $e");
    }
  }
}