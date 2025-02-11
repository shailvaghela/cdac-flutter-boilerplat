import 'dart:developer';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';


class CameraGalleryScreen extends StatefulWidget {
  const CameraGalleryScreen({super.key});

  @override
  State<CameraGalleryScreen> createState() => _CameraGalleryScreenState();
}

class _CameraGalleryScreenState extends State<CameraGalleryScreen> {
  // Variable to hold the selected image file
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

  Future<void> _initializeCamera() async {
    try {
      // Get a list of available cameras
      final cameras = await availableCameras();
      if (kDebugMode) {
        log("$cameras");
        print(cameras);
      }
      if (cameras.isEmpty) {
        _showNoCameraDialog();
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
        _showNoCameraDialog();
      }
      if (kDebugMode) {
        print("----\nException $e while initializing camera");
        print(stackTrace);
      }
    }
  }

  void _showNoCameraDialog() {
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

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      // Take a picture and get the file
      final image = await _controller!.takePicture();

      if (kDebugMode) {
        print("----\nimage taken");
        print(image);
      }

      // Convert the image to a Blob URL
      // Read the image bytes asynchronously
      final bytes = await image.readAsBytes();
      if (kDebugMode) {
        print("----\nimage byted");
      }

      // Create a Blob URL from the image bytes
      final blob = html.Blob([bytes]);

      if (kDebugMode) {
        print("----\nimage blobed");
        // print(image);
      }
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      if (kDebugMode) {
        print("----\nimage url");
        print(blobUrl);
      }
      setState(() {
        _imageUrl = blobUrl;
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Exception $e while capturing image");
        print(stackTrace);
      }
    }
  }

  // Method to pick and display an image file
  Future<void> _pickImage() async {
    try {
      // Pick an image file using file_picker package
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // If user cancels the picker, do nothing
      if (result == null) return;



      // If user picks an image, update the state with the new image file
      setState(() {
        _imageFile = result.files.first;
      });
    } catch (e) {
      // If there is an error, show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // initialize camera
    _initializeCamera();
    setState(() {
      _pictureMode = "camera";
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Capture from Camera
                  if (kDebugMode) {
                    print("Clicked on camera capture");
                  }

                  setState(() {
                    _pictureMode = "camera";
                  });

                  _takePicture();
                },
                child: const Text('Capture'),
              ),
              const SizedBox(width: 20), // Spacing between buttons
              ElevatedButton(
                onPressed: () {
                  // Choose from Gallery
                  if (kDebugMode) {
                    print("Clicked on choose from gallery");
                  }
                  setState(() {
                    _pictureMode = "gallery";
                  });

                  _pickImage();
                },
                child: const Text('Choose from Gallery'),
              ),
            ],
          ),
          const SizedBox(height: 20), // Spacing between buttons and preview
          // Image Preview Area
          Container(
              height: 200, // Adjust height as needed
              width: 200, // Adjust width as needed
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _pictureMode == 'camera' && _imageUrl != null
                  ? Image.network(_imageUrl!)
                  : _pictureMode == "gallery"
                  ? Image.memory(Uint8List.fromList(_imageFile!.bytes!))
                  : const Text("")),
        ],
      ),
    );
  }
}
