import 'dart:async';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Centralized service for device camera hardware management,
/// live viewfinder streams, and biometric photo capture across all platforms.
class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> _cachedCameras = [];
  bool _isQueryingCameras = false;

  /// Check if the app is currently running inside an automated test suite.
  bool get isRunningInTest {
    try {
      return !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Retrieve available physical cameras on the host device.
  /// Gracefully returns an empty list if cameras are unavailable or unsupported.
  Future<List<CameraDescription>> getAvailableCameras({bool forceRefresh = false}) async {
    if (isRunningInTest) return [];
    if (!forceRefresh && _cachedCameras.isNotEmpty) return _cachedCameras;
    if (_isQueryingCameras) return _cachedCameras;

    _isQueryingCameras = true;
    try {
      if (forceRefresh) {
        _cachedCameras = [];
      }
      _cachedCameras = await availableCameras();
    } catch (e) {
      debugPrint('[CameraService] Notice: Could not access hardware cameras: $e');
      _cachedCameras = [];
    } finally {
      _isQueryingCameras = false;
    }
    return _cachedCameras;
  }

  /// Initialize a camera controller for a specific lens direction (front/back).
  Future<CameraController?> initializeCamera({
    CameraLensDirection preferredLens = CameraLensDirection.front,
    ResolutionPreset resolution = ResolutionPreset.medium,
    bool enableAudio = false,
    bool forceRefresh = false,
  }) async {
    if (isRunningInTest) return null;
    try {
      var cameras = await getAvailableCameras(forceRefresh: forceRefresh);
      if (cameras.isEmpty) {
        // Retry with forceRefresh in case permission was just granted by user
        cameras = await getAvailableCameras(forceRefresh: true);
      }
      if (cameras.isEmpty) {
        debugPrint('[CameraService] Notice: No hardware cameras detected on host system.');
        return null;
      }

      // Select camera with preferred lens direction, fallback to external or first available
      CameraDescription selected = cameras.firstWhere(
        (cam) => cam.lensDirection == preferredLens,
        orElse: () => cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.external,
          orElse: () => cameras.first,
        ),
      );

      final controller = CameraController(
        selected,
        resolution,
        enableAudio: enableAudio,
        // camera_web on Chrome does not support custom imageFormatGroup (throws PlatformException)
        imageFormatGroup: kIsWeb ? null : ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      return controller;
    } catch (e) {
      debugPrint('[CameraService] Camera controller initialization error: $e');
      return null;
    }
  }

  /// Capture a reference image using the cross-platform ImagePicker.
  /// Works reliably across Android, iOS, Web, and Desktop environments.
  Future<XFile?> pickOrCapturePhoto({
    ImageSource source = ImageSource.camera,
    CameraDevice preferredCamera = CameraDevice.front,
  }) async {
    if (isRunningInTest) return null;
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        preferredCameraDevice: preferredCamera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 92,
      );
      return photo;
    } catch (e) {
      debugPrint('[CameraService] Photo capture error: $e');
      return null;
    }
  }
}
