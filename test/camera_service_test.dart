import 'package:flutter_test/flutter_test.dart';
import 'package:campus_erp/core/services/camera_service.dart';

void main() {
  group('CameraService Initialization & Testing', () {
    test('CameraService singleton instantiates cleanly', () {
      final service = CameraService();
      expect(service, isNotNull);
    });

    test('CameraService identifies automated test environment', () {
      final service = CameraService();
      expect(service.isRunningInTest, isTrue);
    });

    test('CameraService handles camera query safely in test mode', () async {
      final service = CameraService();
      final cameras = await service.getAvailableCameras();
      expect(cameras, isEmpty);
    });

    test('CameraService handles photo capture safely in test mode', () async {
      final service = CameraService();
      final photo = await service.pickOrCapturePhoto();
      expect(photo, isNull);
    });
  });
}
