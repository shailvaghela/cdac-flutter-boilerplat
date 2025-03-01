import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/services/DatabaseHelper/database_helper.dart';
import 'package:flutter_demo/services/DatabaseHelper/database_helper_web.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/directory_utils.dart';
import '../../../viewmodels/permission_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_text_icon_button.dart';
import '../home/location_widget.dart';
import '../home/profile_photo_widget.dart';

class GeoTagWithPicture extends StatefulWidget {
  const GeoTagWithPicture({super.key});

  @override
  State<GeoTagWithPicture> createState() => _GeoTagWithPictureState();
}

class _GeoTagWithPictureState extends State<GeoTagWithPicture> {
  bool isSaving = false; // Tracks save button state
  bool pictureGetBy = false; // Tracks picture source

  dynamic showVal(dynamic val) {
    if (kDebugMode) {
      log("value is");
      log("$val");
    }

    return val;
  }

  @override
  void initState() {
    final permissionProvider =
  Provider.of<PermissionProvider>(context, listen: false);

    /*if(kIsWeb){
      if(permissionProvider.imageFile!=null){
        permissionProvider.imageFile = null;
      }
    }
    else{
      if(permissionProvider.profilePic!=null){
        permissionProvider.profilePic = null;
      }
    }*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(context);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.greyHundred,
      appBar: MyAppBar.buildAppBar('GeoTag With Picture', true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(8.0),
        width: screenWidth,
        child: FloatingActionButton(
          onPressed: isSaving ? null : _saveGeoTaggedPicture,
          child: isSaving
              ? CircularProgressIndicator(
                  color: AppColors.circularProgressIndicatorBgColor)
              : Text('Save'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          CustomLocationWidget(
            labelText: 'Current Location:',
            isRequired: true,
            latitude: showVal(permissionProvider.latitude),
            longitude: showVal(permissionProvider.longitude),
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
          SizedBox(height: 8.0),
          ProfilePhotoWidget(
            onTap: () async {
              final hasPermission =
              await permissionProvider.requestLocationPermission();
              final hasPermissionCamera =
              await permissionProvider.requestCameraPermission();
              if (hasPermission && hasPermissionCamera) {
                // await permissionProvider.fetchCurrentLocation();
                _showImageSourceDialog(); // Call your image source dialog
              } else {
                kIsWeb? _showImageSourceDialog():_showPermissionDialog(); // Call your permission dialog
              }
            },
            profilePic: permissionProvider.profilePic,
            webProfilePic: permissionProvider.imageFile,
          ),
        ]),
      ),
    );
  }

  /// Saves the geo-tagged picture
  Future<void> _saveGeoTaggedPicture() async {
    /* LogService.debug("User clicked the button.");
    LogService.error("Something went wrong!", Exception("Sample Exception"));
    // Get log file path
    String logFilePath = await LogService.getLogFilePath();
    debugPrint(
        "Logs saved at: $logFilePath"); //Logs saved at: /data/user/0/com.example.flutter_demo/app_flutter/app_logs.txt; path find in system

    String logs = await LogService.readLogs();
    debugPrint(
        "App Logs: $logs"); // App Logs: 2025-01-29 12:01:52.214755 - ERROR - Something went wrong! - Exception: Sample Exception
*/
    final permissionProvider =
        Provider.of<PermissionProvider>(context, listen: false);

    if (kIsWeb? permissionProvider.imageFile == null : permissionProvider.profilePic == null) {
      _showSnackBar("Please select a profile picture", Colors.red);
      return;
    }

    setState(() => isSaving = true);

    try {
      String? savedImagePath;
      // Save the image to the phone directory
      /*if(kIsWeb){
        savedImagePath = await DirectoryUtils.saveImageToDirectory(
            byteArrayToBase64(permissionProvider.imageFile?.bytes as List<int>) as File);
      }
      else{
        savedImagePath = await DirectoryUtils.saveImageToDirectory(
            permissionProvider.profilePic!);
      }*/
      if(!kIsWeb){
      savedImagePath = await DirectoryUtils.saveImageToDirectory(
          permissionProvider.profilePic!);
    }

      // Save to database
      kIsWeb ? await DbHelper().insertGeoPicture(permissionProvider.imageFile!, pictureGetBy ? permissionProvider.address : "Gallery")
          : await DatabaseHelper().insertGeoPicture(savedImagePath!, pictureGetBy ? permissionProvider.address : "Gallery");

      _showSnackBar("Profile picture saved successfully!", Colors.green);

      // Clear the profile picture after saving
      permissionProvider.clearProfilePic();
    } catch (e) {
      _showSnackBar("Error saving picture: $e", Colors.red);
    } finally {
      setState(() => isSaving = false);
    }
  }

  /// Shows a snack bar message
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Shows dialog to choose image source
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
                    setState(() {
                      pictureGetBy =true;
                    });
                    await permissionProvider
                        .handleCameraPermissions(context);
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
                    setState(() {
                      pictureGetBy =false;
                    });
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

  /// Shows permission request dialog
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
              onPressed: () => Navigator.pop(context),
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

  String byteArrayToBase64(List<int> byteArray) {
    return base64Encode(byteArray);
  }
}
