import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

// ignore: use_key_in_widget_constructors
class CameraScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller; // Nullable CameraController
   Future<void>? _initializeControllerFuture;
  List<CameraDescription> cameras = [];
  bool isRearCamera = true;
  double _baseScale = 1.0;
  double currentZoomLevel = 1;


  @override
  void initState() {
    super.initState();
    // Fetch available cameras and initialize the camera controller
    availableCameras().then((value) {
      cameras = value;
      print("cameras---$cameras");
      if (cameras.isNotEmpty) {
        _initializeCamera();
      }
    });
  }

  Future<void> _initializeCamera() async {
    // Initialize the camera controller with the first available camera

    _controller = CameraController(
      cameras.firstWhere((camera) => kIsWeb? camera.lensDirection ==  CameraLensDirection.external:camera.lensDirection ==   CameraLensDirection.front),
      ResolutionPreset.high,
    );

    // Initialize the controller asynchronously
    _initializeControllerFuture = _controller!.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed
    _controller?.dispose();
    super.dispose();
  }

  Future<void> switchCamera() async {
    if (_controller != null) {
      // Switch between front and rear camera
      _controller = CameraController(
        cameras.firstWhere(
                (camera) => camera.lensDirection == (isRearCamera
                ? CameraLensDirection.back
                : CameraLensDirection.front)),
        ResolutionPreset.medium,
      );

      // Reinitialize the controller and update the state
      await _controller!.initialize();
      setState(() {
        isRearCamera = !isRearCamera; // Toggle the camera state
      });
    }
  }

  Future<void> captureImage() async {
    await _initializeControllerFuture;

    // Capture an image
    final image = await _controller!.takePicture();

    // Return the captured image path to the previous screen
    // ignore: use_build_context_synchronously
    Navigator.pop(context, image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyHundred,
      appBar: AppBar(
        title: Text(
          'Camera',
          style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 2.5),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isRearCamera ? Icons.camera_front : Icons.camera_rear,
              color: Colors.black,
            ),
            onPressed: switchCamera,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade700.withAlpha((0.9*255).toInt()),
                Colors.green.withAlpha((0.6*255).toInt())
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Camera is initialized, show the preview
                  return Stack(
                    children: [
                      CameraPreview(_controller!,
                        child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              return GestureDetector(
                                onScaleStart: _handleScaleStart,
                                onScaleUpdate: _handleScaleUpdate,
                              );}),),
                      Positioned(
                        bottom: 30,
                        left: MediaQuery.of(context).size.width / 2 - 30,
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue.shade700,
                          onPressed: captureImage,
                          child: Icon(
                            Icons.camera,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for initialization, show a loading indicator
                  return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade700,
                      ));
                } else {
                  // Handle error if camera initialization fails
                  return Center(child: Text('Error initializing camera'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    // Set the initial base scale to the current zoom level
    _baseScale = currentZoomLevel;
    //debugPrint("_handleScaleStart");
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    //debugPrint("_handleScaleUpdate");

    // Fetch the camera's zoom level limits
    final minZoomLevel = await _controller?.getMinZoomLevel();
    final maxZoomLevel = await _controller?.getMaxZoomLevel();

    // Adjust the scale factor for smoother zooming
    final adjustedScale = (_baseScale * details.scale).clamp(minZoomLevel!, maxZoomLevel!);

    // Update and set the current zoom level
    if (adjustedScale != currentZoomLevel) {
      currentZoomLevel = adjustedScale;
      await _controller!.setZoomLevel(currentZoomLevel);
    }

    debugPrint('Details Scale: ${details.scale}');
    debugPrint('Current Zoom Level: $currentZoomLevel');
    debugPrint('Adjusted Scale: $adjustedScale');

  }

}



/*
class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    // Initialize the camera when the screen is loaded
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    cameraProvider.initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();

    return Scaffold(
      backgroundColor: AppColors.greyHundred,
      appBar: AppBar(
        title: Text(
          'CameraGalleryScreen',
          style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 2.5),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              cameraProvider.isRearCamera
                  ? Icons.camera_front
                  : Icons.camera_rear,
              color: Colors.black,
            ),
            onPressed: () async {
              await cameraProvider.switchCamera();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade700.withOpacity(0.9),
                Colors.green.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cameraProvider.isCameraInitialized
                ? GestureDetector(
              onScaleStart: (details) {
                _baseScale = cameraProvider.zoomLevel;
              },
              onScaleUpdate: (details) {
                double scale = _baseScale * details.scale;
                cameraProvider.setZoomLevel(scale);
              },
              child: CameraPreview(cameraProvider.controller!),
            )
                : Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade700,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              backgroundColor: Colors.blue.shade700,
              onPressed: () async {
                final imagePath = await cameraProvider.captureImage();
                if (imagePath != null) {
                  Navigator.pop(context, imagePath);
                }
              },
              child: Icon(
                Icons.camera,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

