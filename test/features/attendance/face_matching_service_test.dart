import 'dart:convert';
import 'package:campus_erp/core/services/ai_face_recognition_service.dart';
import 'package:campus_erp/core/services/face_matching_service.dart';
import 'package:campus_erp/core/utils/image_crop_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('FaceMatchingService Biometric Tests', () {
    late FaceMatchingService service;

    setUp(() {
      service = FaceMatchingService();
    });

    test('Identical images produce 100% confidence match', () async {
      // Create a dummy 64x64 sample image
      final sampleImg = img.Image(width: 64, height: 64);
      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          sampleImg.setPixelRgb(x, y, x * 3, y * 3, (x + y) * 2);
        }
      }
      final sampleBytes = img.encodeJpg(sampleImg);
      final sampleBase64 = base64Encode(sampleBytes);

      final result = await service.compareFaces(
        liveBytes: sampleBytes,
        enrolledBase64: sampleBase64,
      );

      expect(result.isMatch, isTrue);
      expect(result.confidenceScore, equals(1.0));
      expect(result.confidencePercentage, equals('100.0%'));
      expect(result.statusLabel, contains('Exact Biometric Match'));
    });

    test('Auto-enrolls baseline when enrolled record is null and allowAutoEnroll is true', () async {
      final sampleImg = img.Image(width: 64, height: 64);
      final sampleBytes = img.encodeJpg(sampleImg);

      final result = await service.compareFaces(
        liveBytes: sampleBytes,
        enrolledBase64: null,
        allowAutoEnroll: true,
      );

      expect(result.isMatch, isTrue);
      expect(result.statusLabel, equals('Baseline Auto-Enrolled'));
      expect(result.confidenceScore, greaterThanOrEqualTo(0.95));
    });

    test('Rejects face match when baseline record is null and allowAutoEnroll is false', () async {
      final sampleImg = img.Image(width: 64, height: 64);
      final sampleBytes = img.encodeJpg(sampleImg);

      final result = await service.compareFaces(
        liveBytes: sampleBytes,
        enrolledBase64: null,
        allowAutoEnroll: false,
      );

      expect(result.isMatch, isFalse);
      expect(result.statusLabel, equals('No Baseline Enrolled'));
      expect(result.confidenceScore, equals(0.0));
    });

    test('Completely distinct patterns trigger Biometric Mismatch (< 80%)', () async {
      // Image A: Horizontal gradient
      final imgA = img.Image(width: 64, height: 64);
      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          imgA.setPixelRgb(x, y, x * 4, 0, 0);
        }
      }
      final bytesA = img.encodeJpg(imgA);

      // Image B: Inverted checkerboard
      final imgB = img.Image(width: 64, height: 64);
      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          final isCheck = ((x ~/ 8) + (y ~/ 8)) % 2 == 0;
          imgB.setPixelRgb(x, y, isCheck ? 0 : 255, isCheck ? 0 : 255, isCheck ? 0 : 255);
        }
      }
      final bytesB = img.encodeJpg(imgB);

      final result = await service.compareFaces(
        liveBytes: bytesA,
        enrolledBytes: bytesB,
      );

      expect(result.isMatch, isFalse);
      expect(result.confidenceScore, lessThan(FaceMatchingService.defaultMatchThreshold));
      expect(result.statusLabel, contains('Mismatch'));
    });

    test('FaceMatchingService populates isolated cropped face templates', () async {
      final sampleImg = img.Image(width: 80, height: 80);
      for (int y = 0; y < 80; y++) {
        for (int x = 0; x < 80; x++) {
          sampleImg.setPixelRgb(x, y, 120, 140, 160);
        }
      }
      final sampleBytes = img.encodeJpg(sampleImg);

      final result = await service.compareFaces(
        liveBytes: sampleBytes,
        enrolledBytes: sampleBytes,
      );

      expect(result.isMatch, isTrue);
      expect(result.croppedLiveFace, isNotNull);
      expect(result.croppedEnrolledFace, isNotNull);
      expect(result.isLivenessPassed, isTrue);
    });

    test('Template-guided detection isolates off-center face from wide baseline frame', () async {
      // 1. Create a centered live face (64x64) with skin tone and features
      final liveImg = img.Image(width: 64, height: 64);
      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          // Warm skin tone
          liveImg.setPixelRgb(x, y, 180, 125, 95);
        }
      }
      // Eyes (dark pixels)
      for (int y = 20; y <= 24; y++) {
        for (int x = 18; x <= 24; x++) {
          liveImg.setPixelRgb(x, y, 30, 20, 15);
        }
        for (int x = 40; x <= 46; x++) {
          liveImg.setPixelRgb(x, y, 30, 20, 15);
        }
      }
      // Mouth
      for (int y = 44; y <= 48; y++) {
        for (int x = 24; x <= 40; x++) {
          liveImg.setPixelRgb(x, y, 140, 60, 50);
        }
      }
      final liveBytes = img.encodeJpg(liveImg);

      // 2. Create wide room photo (192x120) with gray background and the face on the right edge
      final wideEnrolledImg = img.Image(width: 192, height: 120);
      for (int y = 0; y < 120; y++) {
        for (int x = 0; x < 192; x++) {
          wideEnrolledImg.setPixelRgb(x, y, 70, 75, 80); // Gray classroom wall
        }
      }
      // Place the face at x: 120..183, y: 25..88 (right edge)
      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          final p = liveImg.getPixel(x, y);
          wideEnrolledImg.setPixel(120 + x, 25 + y, p);
        }
      }
      final enrolledBytes = img.encodeJpg(wideEnrolledImg);

      final result = await service.compareFaces(
        liveBytes: liveBytes,
        enrolledBytes: enrolledBytes,
      );

      // Template guidance successfully found the face on the right
      expect(result.isMatch, isTrue);
      expect(result.confidenceScore, greaterThanOrEqualTo(FaceMatchingService.defaultMatchThreshold));
      expect(result.croppedEnrolledFace, isNotNull);
    });

    test('ImageCropUtils crops landscape camera image to 1:1 circular alpha PNG', () {
      // Landscape 160x100
      final wide = img.Image(width: 160, height: 100);
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 160; x++) {
          wide.setPixelRgb(x, y, 200, 100, 50);
        }
      }
      final rawBytes = img.encodeJpg(wide);

      final cropResult = ImageCropUtils.cropToCircularGrid(rawBytes);

      // Decoded PNG should be square of side min(160, 100) = 100
      final decodedPng = img.decodePng(cropResult.circularPngBytes);
      expect(decodedPng, isNotNull);
      expect(decodedPng!.width, equals(100));
      expect(decodedPng.height, equals(100));

      // Center pixel should be opaque
      expect(decodedPng.getPixel(50, 50).a, equals(255));

      // Corner pixel (0, 0) should be transparent (outside circular reticle)
      expect(decodedPng.getPixel(0, 0).a, equals(0));
    });

    test('AiFaceRecognitionService verifies identical frames with 1.0 confidence', () async {
      final sampleImg = img.Image(width: 96, height: 96);
      for (int y = 0; y < 96; y++) {
        for (int x = 0; x < 96; x++) {
          sampleImg.setPixelRgb(x, y, 180, 140, 100);
        }
      }
      final rawBytes = img.encodeJpg(sampleImg);

      final aiService = AiFaceRecognitionService();
      final aiResult = await aiService.verifyFaces(
        liveBytes: rawBytes,
        enrolledBytes: rawBytes,
      );

      expect(aiResult.isMatch, isTrue);
      expect(aiResult.confidenceScore, equals(1.0));
      expect(aiResult.statusLabel, contains('Exact AI Biometric Match'));
    });

    test('FaceMatchingService integrates AI engine metadata and matched features', () async {
      final sampleImg = img.Image(width: 96, height: 96);
      for (int y = 0; y < 96; y++) {
        for (int x = 0; x < 96; x++) {
          sampleImg.setPixelRgb(x, y, 200, 150, 110);
        }
      }
      final rawBytes = img.encodeJpg(sampleImg);

      final matchResult = await service.compareFaces(
        liveBytes: rawBytes,
        enrolledBytes: rawBytes,
      );

      expect(matchResult.isMatch, isTrue);
      expect(matchResult.confidenceScore, equals(1.0));
      expect(matchResult.statusLabel, isNotEmpty);
    });
  });
}

