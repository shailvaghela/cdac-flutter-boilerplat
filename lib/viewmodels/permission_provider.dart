import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../views/screens/home/camera_screen.dart';

class PermissionProvider extends ChangeNotifier {
  bool cameraPermissionGranted = false;
  bool microphonePermissionGranted = false;
  double? latitude;
  double? longitude;
  String address = '',location='Unknown';
  bool isLoading = false;

  File? _profilePic;

  // Getter for profilePic
  File? get profilePic => _profilePic;

  // Setter for profilePic
  set profilePic(File? profilePic) {
    _profilePic = profilePic;
    notifyListeners(); // Optionally notify listeners if needed
  }


  // Method to set profilePic
  void setProfilePic(File? newProfilePic) {
    _profilePic = newProfilePic;
    notifyListeners();  // Notify listeners to update UI
  }


  Future<void> fetchCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.requestPermission();
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        isLoading = false;
        notifyListeners();
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // Get the current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best
        )
      );

      latitude = position.latitude;
      longitude = position.longitude;

      // Get the address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );
      location = '${position.latitude}, ${position.longitude}';
      debugPrint("location---$location");
      address =
      '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea} - ${placemarks.first.postalCode}, ${placemarks.first.country}.';
      debugPrint("address---$address");
      notifyListeners();

    } catch (e) {
      address = 'Failed to fetch location: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLocation(double lat, double lng) async {
    latitude = lat;
    longitude = lng;
    notifyListeners();

    // Fetch address from coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      location = '$lat, $lng';
      address =
      '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea} - ${placemarks.first.postalCode}, ${placemarks.first.country}.';
    } catch (e) {
      address = 'Failed to fetch address.';
    }

    notifyListeners();
  }

  // Method to handle location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      return false; // User must enable permissions from app settings
    }
    return false;
  }

 /* Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      cameraPermissionGranted = true;
      return true;
    } else if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        cameraPermissionGranted = true;
        return true;
      }
    }
    return false;
  }

  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      microphonePermissionGranted = true;
      return true;
    } else if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        microphonePermissionGranted = true;
        return true;
      }
    }
    return false;
  }*/

  // Request Camera Permission
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      cameraPermissionGranted = true;
      return true;
    } else if (status.isDenied) {
      // Request permission if denied
      status = await Permission.camera.request();
      if (status.isGranted) {
        cameraPermissionGranted = true;
        return true;
      } else if (status.isPermanentlyDenied) {
        // If permanently denied, inform the user and guide them to settings
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, guide user to settings
      return false;
    }
    return false;
  }

  // Request Microphone Permission (same logic as camera)
  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      return false;
    }
    return false;
  }

  // Handle Camera and Microphone Permissions and navigate to camera screen if granted
  Future<void> handleCameraAndMicrophonePermissions(BuildContext context) async {
    bool cameraGranted = await requestCameraPermission();
    bool microphoneGranted = await requestMicrophonePermission();

    if (cameraGranted && microphoneGranted) {
      // Navigate to Camera screen if permissions are granted
      await _navigateToCameraScreen(context);
    } else {
      final deniedPermission = cameraGranted ? 'Microphone' : 'Camera';
      _showSettingsDialog(context, deniedPermission);
    }
  }

 /* Future<void> handleCameraAndMicrophonePermissions(BuildContext context) async {
    bool cameraGranted = await requestCameraPermission();
    bool microphoneGranted = await requestMicrophonePermission();

    if (cameraGranted && microphoneGranted) {
      // ignore: use_build_context_synchronously
      await _navigateToCameraScreen(context);
    } else {
      final deniedPermission = cameraGranted ? 'Microphone' : 'Camera';
      // ignore: use_build_context_synchronously
      _showSettingsDialog(context, deniedPermission);
    }
  }*/

// Navigate to Camera Screen and get the selected image
  Future<void> _navigateToCameraScreen(BuildContext context) async {
    // Navigate to the CameraScreen and get the image
    final image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );

    if (image != null) {
      // Update the profilePic in the provider
      setProfilePic(File(image));
    }
  }
  // Pick image from gallery
  Future<void> pickImageFromGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setProfilePic(File(pickedFile.path)); // Update profilePic in provider
    }
  }

  void _showSettingsDialog(BuildContext context, String deniedPermission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('$deniedPermission permission is required. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
