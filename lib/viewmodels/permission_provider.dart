import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:universal_html/html.dart' as html;
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

  String? _imageFile;

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
  void setWebProfilePic(String? imageFile) {
    _imageFile = imageFile;
    notifyListeners();  // Notify listeners to update UI
  }

  set imageFile(String? imageFile) {
    _imageFile = imageFile;
    notifyListeners(); // Optionally notify listeners if needed
  }

  String? get imageFile => _imageFile;

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
          if (kDebugMode) {
            print("addressDecoded---$addressDecoded");
          }
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
    log("Camera permission status: ${status.toString()}");

    if (status.isGranted) {
      log("Camera permission isGranted: ${status.toString()}");
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
      log("Camera permission isDenied: ${status.toString()}");

    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, guide user to settings
      return false;
    }
    log("Camera permission not get: ${status.toString()}");

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

  // Handle camera and Microphone Permissions and navigate to camera screen if granted
  Future<void> handleCameraPermissions(BuildContext context) async {

      try{
        final camera = await availableCameras();
        if(camera.isEmpty){
          _showNoCameraDialog(context);
        }
      }catch(e){
        _showNoCameraDialog(context);
      }

    bool cameraGranted = await requestCameraPermission();
    // bool microphoneGranted = await requestMicrophonePermission();
    log("handle camera permission status: ${cameraGranted.toString()}");

    if (cameraGranted) {
      // Navigate to camera screen if permissions are granted
      await _navigateToCameraScreen(context);
      log("handle camera permission granted: ${cameraGranted.toString()}");

    } else {
      log("handle camera permission denied: ${cameraGranted.toString()}");

      final deniedPermission = 'camera';
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
      final deniedPermission = cameraGranted ? 'Microphone' : 'camera';
      // ignore: use_build_context_synchronously
      _showSettingsDialog(context, deniedPermission);
    }
  }*/
  Future<String> convertBlobUrlToBase64(String blobUrl) async {
    final completer = Completer<String>();

    // Create an HTTP request to fetch the Blob URL
    final request = html.HttpRequest();

    // Open the request to the provided Blob URL
    request.open('GET', blobUrl, async: true);

    // Set response type as 'arraybuffer' to get the raw byte data
    request.responseType = 'arraybuffer';

    // Listen for the completion of the request
    request.onLoadEnd.listen((e) {
      if (request.status == 200) {
        final response = request.response;
        final bytes = response.asUint8List(); // Convert to Uint8List

        // Convert bytes to Base64 string
        final base64String = base64Encode(bytes);

        // Complete the future with the Base64 string
        completer.complete(base64String);
      } else {
        completer.completeError('Failed to fetch Blob URL');
      }
    });

    // Send the request
    request.send();

    return completer.future;
  }
// Navigate to camera Screen and get the selected image
  Future<void> _navigateToCameraScreen(BuildContext context) async {
    // Navigate to the CameraScreen and get the image
    final image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );

    if (kDebugMode) {
      print("camimagefile$image");
    }

    if (image != null) {
      // Update the profilePic in the provider
      if(kIsWeb){
        var base64String = await convertBlobUrlToBase64(image);
        if(kDebugMode){
          print("blob url to base 64");
          print(image);
          print(base64String);
        }

        // final bytes = await image.readAsBytes();
        // if(bytes==null) return;
        // final base64String = base64Encode(bytes); // Encode to Base64
        // // Image.memory(base64Decode(base64String));

        setWebProfilePic(base64String);
      }
      else{
        setProfilePic(File(image));
      }
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
        withData: true, // Ensure we get bytes
      );

      if (result == null) return; // User canceled

      final bytes = result.files.first.bytes;
      if (bytes == null) return;

      final base64String = base64Encode(bytes); // Encode to Base64
      // Image.memory(base64Decode(base64String));

     setWebProfilePic(base64String);

    } catch (e) {
      log(e.toString());
    }
  }
  Future<void> _takePictureOnWeb() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes(); // Convert image to bytes
      final base64String = base64Encode(bytes); // Encode to Base64

      setWebProfilePic(base64String);

    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while capturing image");
        log(stackTrace.toString());
      }
    }
  }


  Future<void> initializeCamera(BuildContext context) async {
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
    kIsWeb? _imageFile = '' : _profilePic = null;
    notifyListeners();
  }



}
