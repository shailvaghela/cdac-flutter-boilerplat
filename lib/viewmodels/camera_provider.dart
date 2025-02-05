import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/services/LogService/log_service_new.dart';
import 'package:logger/logger.dart';

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
    LogServiceNew.logToFile(
      message: "Attempting to initialize camera",
      methodName: "initializeCamera",
      screenName: "CameraProvider",
      level: Level.debug,
    );
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front),
          ResolutionPreset.medium,
        );
        _initializeControllerFuture = _controller!.initialize();
        notifyListeners();
      }
      LogServiceNew.logToFile(
        message: "Initialized camera",
        methodName: "initializeCamera",
        screenName: "CameraProvider",
        level: Level.debug,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while initializing camera");
        print(stackTrace);
      }
      LogServiceNew.logToFile(
        message: "Exception $e while initializing camera",
        methodName: "initializeCamera",
        screenName: "CameraProvider",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );
    }
  }

  // Switch between front and rear camera
  Future<void> switchCamera() async {
    LogServiceNew.logToFile(
      message: "Switching camera",
      methodName: "switchCamera",
      screenName: "CameraProvider",
      level: Level.debug,
    );
    try {
      if (_controller != null && cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.firstWhere((camera) =>
              camera.lensDirection ==
              (isRearCamera
                  ? CameraLensDirection.back
                  : CameraLensDirection.front)),
          ResolutionPreset.medium,
        );
        await _controller!.initialize();
        isRearCamera = !isRearCamera;
        notifyListeners();
      }
      LogServiceNew.logToFile(
        message: "Switched camera",
        methodName: "switchCamera",
        screenName: "CameraProvider",
        level: Level.debug,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while switching camera");
        print(stackTrace);
      }
      LogServiceNew.logToFile(
        message: "Exception $e while switching camera",
        methodName: "switchedCamera",
        screenName: "CameraProvider",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );
    }
  }

  // Capture an image
  Future<String?> captureImage() async {
    LogServiceNew.logToFile(
      message: "Attempting capture image",
      methodName: "captureImage",
      screenName: "CameraProvider",
      level: Level.debug,
    );
    try {
      if (_controller != null) {
        await _initializeControllerFuture;
        final image = await _controller!.takePicture();
        LogServiceNew.logToFile(
          message: "Captured Image",
          methodName: "captureImage",
          screenName: "CameraProvider",
          level: Level.debug,
        );
        return image.path;
      }
      LogServiceNew.logToFile(
        message: "Captured Image because controller was null",
        methodName: "captureImage",
        screenName: "CameraProvider",
        level: Level.warning,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while capturing image camera");
        print(stackTrace);
      }
      LogServiceNew.logToFile(
        message: "Exception $e while capturing image camera",
        methodName: "captureImage",
        screenName: "CameraProvider",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );
    }
    return null;
  }

  // Zoom in or out
  Future<void> setZoomLevel(double zoom) async {
    LogServiceNew.logToFile(
      message: "Attempting to set zoom level to $zoom",
      methodName: "captureImage",
      screenName: "CameraProvider",
      level: Level.debug,
    );
    try {
      if (_controller != null) {
        final minZoomLevel = await _controller?.getMinZoomLevel();
        final maxZoomLevel = await _controller?.getMaxZoomLevel();
        final adjustedScale = (zoom).clamp(minZoomLevel!, maxZoomLevel!);

        if (adjustedScale != currentZoomLevel) {
          currentZoomLevel = adjustedScale;
          await _controller!.setZoomLevel(currentZoomLevel);

          notifyListeners();
        }
        LogServiceNew.logToFile(
          message: "Set zoom level to $zoom",
          methodName: "captureImage",
          screenName: "CameraProvider",
          level: Level.debug,
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while setting zoom level");
        print(stackTrace);
      }
      LogServiceNew.logToFile(
        message: "Exception $e while setting zoom level",
        methodName: "captureImage",
        screenName: "CameraProvider",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );
    }
  }

  // Dispose camera controller
  void disposeController() {
    _controller?.dispose();
    super.dispose();
  }
}
