import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_dialog_show_full_image.dart';

class GeoPictureItem extends StatelessWidget {
  final Map<String, dynamic> profile;

  // ignore: use_super_parameters
  const GeoPictureItem({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("coordinates--");
    }

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
            onTap: () {
              showProfileImageDialog(context, profile['picture']);
            },
            child: kIsWeb ?  Image.memory(base64Decode(profile['picture'])) :Image(
              image: FileImage(File(profile['picture'])),
              // ✅ Wrap FileImage in Image
              width: MediaQuery.of(context).size.width * 0.15,
              // 15% of screen width
              height: MediaQuery.of(context).size.width * 0.15,
              // Keep it square
              fit: BoxFit.cover, // Adjust how the image fits
            ),
          ),
          /*GestureDetector(
            child: CircleAvatar(
              backgroundImage: FileImage(File(profile['picture'])),
            ),
          ),*/
          title: Text(
            profile['currentlocation'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  List<int> base64ToByteArray(String base64String) {
    return base64Decode(base64String);
  }
}
