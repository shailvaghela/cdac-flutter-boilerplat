import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras = [];
  bool isRearCamera = true;
  // ignore: unused_field
  final double _baseScale = 1.0;
  double currentZoomLevel = 1.0;

  CameraController? get controller => _controller;
  double get zoomLevel => currentZoomLevel;
  bool get isCameraInitialized => _controller != null;

  // Initializes the camera
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller!.initialize();
      notifyListeners();
    }
  }

  // Switch between front and rear camera
  Future<void> switchCamera() async {
    if (_controller != null && cameras.isNotEmpty) {
      _controller = CameraController(
        cameras.firstWhere(
                (camera) => camera.lensDirection == (isRearCamera
                ? CameraLensDirection.back
                : CameraLensDirection.front)),
        ResolutionPreset.medium,
      );
      await _controller!.initialize();
      isRearCamera = !isRearCamera;
      notifyListeners();
    }
  }

  // Capture an image
  Future<String?> captureImage() async {
    if (_controller != null) {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      return image.path;
    }
    return null;
  }

  // Zoom in or out
  Future<void> setZoomLevel(double zoom) async {
    if (_controller != null) {
      final minZoomLevel = await _controller?.getMinZoomLevel();
      final maxZoomLevel = await _controller?.getMaxZoomLevel();
      final adjustedScale = (zoom).clamp(minZoomLevel!, maxZoomLevel!);

      if (adjustedScale != currentZoomLevel) {
        currentZoomLevel = adjustedScale;
        await _controller!.setZoomLevel(currentZoomLevel);
        notifyListeners();
      }
    }
  }

  // Dispose camera controller
  void disposeController() {
    _controller?.dispose();
    super.dispose();
  }
}
