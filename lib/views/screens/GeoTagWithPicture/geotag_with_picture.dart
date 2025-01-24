import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../viewmodels/permission_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/customTextIcon_button.dart';
import '../home/location_widget.dart';
import '../home/profile_photo_widget.dart';

class GeoTagWithPicture extends StatefulWidget {
  const GeoTagWithPicture({super.key});

  @override
  State<GeoTagWithPicture> createState() => _GeoTagWithPictureState();
}

class _GeoTagWithPictureState extends State<GeoTagWithPicture> {
  List<Map<String, dynamic>> userProfiles = [];
  List<Map<String, dynamic>> filteredProfiles = [];
  String searchQuery = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(context);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: AppColors.greyHundred,
        appBar: MyAppBar.buildAppBar('GeoTag With Picture', false),
        body: Column(
            children: [
              CustomLocationWidget(
                labelText: 'Current Location:',
                isRequired: true,
                latitude: permissionProvider.latitude,
                longitude: permissionProvider.longitude,
                initialAddress: permissionProvider.address.toString(),
                isLoading: permissionProvider.isLoading,
                mapHeight: screenHeight * 0.5,
                mapWidth: screenWidth * 1,
                onRefresh: () async {
                  await permissionProvider.fetchCurrentLocation();
                },
                onMapTap: (point) async {
                  await permissionProvider.setLocation(
                      point.latitude, point.longitude);
                },
              ),

              ProfilePhotoWidget(
                onTap: () async {
                  final hasPermission =
                  await permissionProvider.requestLocationPermission();
                  if (hasPermission) {
                    // await permissionProvider.fetchCurrentLocation();
                    _showImageSourceDialog(); // Call your image source dialog
                  } else {
                    _showPermissionDialog(); // Call your permission dialog
                  }
                },
                profilePic: permissionProvider.profilePic,
              ),
            ]
        )
    );
  }

  Future<void> _showImageSourceDialog() async {
    final permissionProvider =
    Provider.of<PermissionProvider>(context, listen: false);

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Choose image source'),
              actions: [
                CustomTextIconButton(
                  icon: Icons.camera,
                  label: 'Camera',
                  onPressed: () async {
                    await permissionProvider
                        .handleCameraAndMicrophonePermissions(context);
                    Navigator.pop(context); // Close the dialog
                  },
                  backgroundColor: Colors.blue[50],
                  textColor: Colors.blue,
                  iconColor: Colors.blue,
                ),
                CustomTextIconButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: () async {
                    await permissionProvider.pickImageFromGallery(context);
                    Navigator.pop(context); // Close the dialog
                  },
                  backgroundColor: Colors.blue[50],
                  textColor: Colors.blue,
                  iconColor: Colors.blue,
                ),
              ]);
        });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text(
            'Location permissions are required for this feature. Please enable them in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                openAppSettings();
                Navigator.pop(context);
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

}