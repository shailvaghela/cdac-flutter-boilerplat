import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final VoidCallback onTap; // Triggered when tapping on the photo
  final File? profilePic; // The profile picture file (nullable)
  final PlatformFile? webProfilePic; // The profile picture file (nullable)


  // ignore: use_super_parameters
  const ProfilePhotoWidget({
    Key? key,
    required this.onTap,
    this.profilePic,
    this.webProfilePic
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("webProfilePic $webProfilePic");
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 50, // Adjust the radius as needed
        backgroundColor: Colors.grey[300], // Background color for empty profile
        child: ClipOval(
          child: profilePic != null || webProfilePic != null
              ? kIsWeb? Image.memory(Uint8List.fromList(webProfilePic!.bytes!)) : Image.file(
            profilePic!,
            width: 100, // Diameter of the CircleAvatar
            height: 100,
            fit: BoxFit.cover, // Ensures the image fits properly
          )
              : const Icon(
            Icons.camera_alt, // Default icon when no photo is selected
            size: 40,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
