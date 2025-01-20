import 'dart:io';

import 'package:flutter/material.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final VoidCallback onTap; // Triggered when tapping on the photo
  final File? profilePic; // The profile picture file (nullable)

  const ProfilePhotoWidget({
    Key? key,
    required this.onTap,
    this.profilePic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 50, // Adjust the radius as needed
        backgroundColor: Colors.grey[300], // Background color for empty profile
        child: ClipOval(
          child: profilePic != null
              ? Image.file(
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
