import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import '../views/screens/home/camera_screen.dart';
import 'package:http/http.dart' as http;

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

  PlatformFile? _imageFile;

  // can be camera or gallery
  late String _pictureMode;

  // CameraGalleryScreen package for web platform
  // require secure context; which means:
  // either localhost
  // on IP/Domain with valid HTTPS certificate
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  // To store URL for captured image
  String? _imageUrl;

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

  // Method to set profilePic
  void setWebProfilePic(PlatformFile? imageFile) {
    _imageFile = imageFile;
    notifyListeners();  // Notify listeners to update UI
  }

  set imageFile(PlatformFile? imageFile) {
    _imageFile = imageFile;
    notifyListeners(); // Optionally notify listeners if needed
  }

  PlatformFile? get imageFile => _imageFile;

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

      location = '${position.latitude}, ${position.longitude}';

      print("kIsWeb: $kIsWeb");
      // Choose geocoding method based on platform
      if (kIsWeb) {
        await _getAddressFromCoordinatesWeb(latitude!, longitude!);
      } else {
        await _getAddressFromCoordinates(latitude!, longitude!);
      }
      notifyListeners();
    } catch (e) {
      address = 'Failed to fetch location: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // address = '${place.name}, ${place.locality}, ${place.country}';
        address =
        '${place.street}, ${place.locality}, ${place.administrativeArea} - ${place.postalCode}, ${place.country}.';
      } else {
        address = "Address not found.";
      }
    } catch (e) {
      address = "Error retrieving address.";
    }
  }

  // Web-compatible geocoding using OpenStreetMap's Nominatim API
  Future<void> _getAddressFromCoordinatesWeb(double lat, double lon) async {
    final String nominatimUrl =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon';

    try {
      final response = await http.get(Uri.parse(nominatimUrl));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['address'] != null) {
          final addressDecoded = decoded['address'];
          print("addressDecoded---$addressDecoded");
          address =
          '${addressDecoded['amenity'] ?? ''}, ${addressDecoded['road'] ?? ''}, ${addressDecoded['city'] ?? addressDecoded['town'] ?? ''} - ${addressDecoded['postcode'] ?? ''}, ${addressDecoded['country'] ?? ''}.';
        } else {
          address = "Address not found (Web).";
        }
      } else {
        address = "Error retrieving address (Web).";
      }
    } catch (e) {
      address = "Error retrieving address (Web).";
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

  // Request CameraGalleryScreen Permission
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    log("CameraGalleryScreen permission status: ${status.toString()}");

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
  // Future<bool> requestMicrophonePermission() async {
  //   var status = await Permission.microphone.status;

  //   if (status.isGranted) {
  //     return true;
  //   } else if (status.isDenied) {
  //     status = await Permission.microphone.request();
  //     if (status.isGranted) {
  //       return true;
  //     } else if (status.isPermanentlyDenied) {
  //       return false;
  //     }
  //   } else if (status.isPermanentlyDenied) {
  //     return false;
  //   }
  //   return false;
  // }

  // Handle CameraGalleryScreen and Microphone Permissions and navigate to camera screen if granted
  Future<void> handleCameraPermissions(BuildContext context) async {
    bool cameraGranted = await requestCameraPermission();
    // bool microphoneGranted = await requestMicrophonePermission();
    log("handle CameraGalleryScreen permission status: ${cameraGranted.toString()}");

    if (cameraGranted) {
      // Navigate to CameraGalleryScreen screen if permissions are granted
      kIsWeb ? await _initializeCamera(context) : await _navigateToCameraScreen(context);
      log("handle CameraGalleryScreen permission granted: ${cameraGranted.toString()}");

    } else {
      log("handle CameraGalleryScreen permission denied: ${cameraGranted.toString()}");

      final deniedPermission = 'CameraGalleryScreen';
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
      final deniedPermission = cameraGranted ? 'Microphone' : 'CameraGalleryScreen';
      // ignore: use_build_context_synchronously
      _showSettingsDialog(context, deniedPermission);
    }
  }*/

// Navigate to CameraGalleryScreen Screen and get the selected image
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
/*  Future<void> pickImageFromGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setProfilePic(File(pickedFile.path)); // Update profilePic in provider
    }
  }*/

  Future<void> pickImageFromGallery(BuildContext context) async {

    if (kIsWeb) {

      await pickImageFromWeb();

    } else {
      await pickImageFromMobile(context);
    }
  }

  Future<void> pickImageFromMobile(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      // Use dart:io File only for non-web platforms
      setProfilePic(File(pickedFile.path)); // Update profilePic in provider
    }
  }

  Future<void> pickImageFromWeb() async {
    try {
      // Pick an image file using file_picker package
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // If user cancels the picker, do nothing
      if (result == null) return;

      // If user picks an image, update the state with the new image file

      _imageFile = result.files.first;

     setWebProfilePic(_imageFile);

    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _initializeCamera(BuildContext context) async {
    try {
      // Get a list of available cameras
      final cameras = await availableCameras();
      if (kDebugMode) {
        log("$cameras");
        print(cameras);
      }
      if (cameras.isEmpty) {
        _showNoCameraDialog(context);
      } else {
        // Select the first camera
        final camera = cameras.first;
        if (kDebugMode) {
          print("----\ncamera is ");
          print(camera);
        }

        // Create a CameraController
        _controller = CameraController(
          camera,
          ResolutionPreset.medium,
        );
        if (kDebugMode) {
          print("----\ncontroller");
          print(_controller);
        }

        // Initialize the controller
        _initializeControllerFuture = _controller!.initialize();
      }
    } catch (e, stackTrace) {
      if (e is CameraException && e.code == "cameraNotFound") {
        _showNoCameraDialog(context);
      }
      if (kDebugMode) {
        print("----\nException $e while initializing camera");
        print(stackTrace);
      }
    }
  }

  void _showNoCameraDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No camera Detected'),
          content: Text('Please connect a webcam to use this feature.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('Retry'),
            ),
          ],
        );
      },
    );
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

// Method to clear the profile picture
  void clearProfilePic() {
    kIsWeb? _imageFile = null : _profilePic = null;
    notifyListeners();
  }



}
