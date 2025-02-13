import 'dart:convert';
import 'dart:io';
// import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/EncryptionService/encryption_service.dart';

class ProfileListItem extends StatelessWidget {
  final Map<String, dynamic> profile;

  final EncryptionService encryptionService;
  final Function(Map<String, dynamic>) onEditProfile;
  final Function(Map<String, dynamic>) onViewProfile;
  final Function(Map<String, dynamic>) onDeleteProfile;
  final Function(BuildContext, double, double, String) onShowMapDialog;

  // ignore: use_super_parameters
  const ProfileListItem({
    Key? key,
    required this.profile,
    required this.encryptionService,
    required this.onEditProfile,
    required this.onViewProfile,
    required this.onDeleteProfile,
    required this.onShowMapDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> coordinates =
        encryptionService.decrypt(profile['latlong']).toString().split(', ');
    if (kDebugMode) {
      print("coordinates--$coordinates");
    }

    if (kDebugMode) {
      print("useridSearch${profile['id']}");
    }

    // ignore: unrelated_type_equality_checks
    final double lat = (coordinates is String && coordinates == 'Unknown')
        ? 18.520430
        : double.parse(coordinates[0]);
    // ignore: unrelated_type_equality_checks
    final double long = (coordinates is String && coordinates == 'Unknown')
        ? 73.856743
        : double.parse(coordinates[1]);

    final String decryptedName =
        encryptionService.decrypt(profile['firstname']);
    final String decryptedContact =
        encryptionService.decrypt(profile['contact']);
    final String decryptedProfilePic =
        encryptionService.decrypt(profile['profilePic']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(4.0),
          leading: GestureDetector(
            onTap: () => _showProfileImageDialog(context, decryptedProfilePic),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: getProfileImage(decryptedProfilePic),
            )),
          title: Text(
            decryptedName.isNotEmpty ? decryptedName : 'No Name',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Contact: $decryptedContact',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.location_on_outlined,
                        color: Colors.yellow[900]),
                    onPressed: () => onShowMapDialog(
                      context,
                      lat,
                      long,
                      encryptionService
                          .decrypt(profile['currentlocation'].toString()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => onEditProfile(profile),
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.green),
                    onPressed: () => onViewProfile(profile),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => onDeleteProfile(profile),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileImageDialog(BuildContext context, String profilePicPath) {
    if (profilePicPath.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              kIsWeb?Image.memory(base64Decode(profilePicPath)): Image.file(
                File(profilePicPath),
                fit: BoxFit.contain,
              ),
              const Divider(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No profile image available')),
      );
    }
  }

  List<int> base64ToByteArray(String base64String) {
    return base64Decode(base64String);
  }

  ImageProvider getProfileImage(String decryptedProfilePic) {
    // Check if decryptedProfilePic is not empty
    if (decryptedProfilePic.isNotEmpty) {
      // If we're on the web
      if (kIsWeb) {
        // Convert the Base64 string to bytes and load it as a memory image
        
        return Image.memory(base64Decode(decryptedProfilePic)).image;
      } else {
        // If it's a non-web platform, use FileImage with the file path
        return FileImage(File(decryptedProfilePic));
      }
    } else {
      // If no profile pic, use the default image
      return const AssetImage('assets/images/default_profile.png');
    }
  }
}
