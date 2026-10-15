import 'package:campus_erp/core/services/mlkit_face_service.dart';
import 'package:campus_erp/features/attendance/presentation/widgets/liveness_camera_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  group('LivenessCameraOverlay State Machine & Anti-Proxy Tests', () {
    testWidgets('Initial state is waitingForFace and prompts user to position face', (tester) async {
      bool livenessPassed = false;
      final key = GlobalKey<LivenessCameraOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LivenessCameraOverlay(
                  key: key,
                  onLivenessPassed: () => livenessPassed = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(key.currentState?.currentStep, equals(LivenessStep.waitingForFace));
      expect(key.currentState?.eyesWereClosed, isFalse);
      expect(find.text('Position your face in the frame'), findsOneWidget);
      expect(livenessPassed, isFalse);
    });

    testWidgets('Detecting open eyes transitions to promptBlink ("Please Blink Your Eyes")', (tester) async {
      bool livenessPassed = false;
      final key = GlobalKey<LivenessCameraOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LivenessCameraOverlay(
                  key: key,
                  onLivenessPassed: () => livenessPassed = true,
                ),
              ],
            ),
          ),
        ),
      );

      // User positions face with open eyes
      key.currentState?.processProbabilities(leftEye: 0.95, rightEye: 0.92);
      await tester.pump();

      expect(key.currentState?.currentStep, equals(LivenessStep.promptBlink));
      expect(find.text('Please Blink Your Eyes'), findsOneWidget);
      expect(key.currentState?.eyesWereClosed, isFalse);
      expect(livenessPassed, isFalse);
    });

    testWidgets('Anti-Proxy Protection: Static photo with continuously open eyes NEVER verifies', (tester) async {
      bool livenessPassed = false;
      final key = GlobalKey<LivenessCameraOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LivenessCameraOverlay(
                  key: key,
                  onLivenessPassed: () => livenessPassed = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Attacker holds up a printed paper photo of faculty member (eyes always open 0.95)
      for (int frame = 0; frame < 50; frame++) {
        key.currentState?.processProbabilities(leftEye: 0.95, rightEye: 0.95);
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Must remain in promptBlink, eyes never closed, never verified!
      expect(key.currentState?.currentStep, equals(LivenessStep.promptBlink));
      expect(key.currentState?.eyesWereClosed, isFalse);
      expect(find.text('Please Blink Your Eyes'), findsOneWidget);
      expect(livenessPassed, isFalse);
    });

    testWidgets('Valid Open -> Closed -> Open blink cycle confirms liveness and fires callback', (tester) async {
      bool livenessPassed = false;
      final key = GlobalKey<LivenessCameraOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LivenessCameraOverlay(
                  key: key,
                  onLivenessPassed: () => livenessPassed = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Phase 1: Eyes open initially (> 0.60)
      key.currentState?.processProbabilities(leftEye: 0.90, rightEye: 0.92);
      await tester.pump();
      expect(key.currentState?.currentStep, equals(LivenessStep.promptBlink));
      expect(find.text('Please Blink Your Eyes'), findsOneWidget);

      // Phase 2: Eyes closed during blink (< 0.25)
      key.currentState?.processProbabilities(leftEye: 0.12, rightEye: 0.10);
      await tester.pump();
      expect(key.currentState?.eyesWereClosed, isTrue);
      expect(key.currentState?.currentStep, equals(LivenessStep.promptBlink));

      // Phase 3: Eyes reopened after blink (> 0.70)
      key.currentState?.processProbabilities(leftEye: 0.88, rightEye: 0.91);
      await tester.pump();

      // State transitions to verified immediately
      expect(key.currentState?.currentStep, equals(LivenessStep.verified));
      expect(find.text('Liveness Verified! Capturing...'), findsOneWidget);

      // Callback triggers after 500ms delay
      expect(livenessPassed, isFalse);
      await tester.pump(const Duration(milliseconds: 550));
      expect(livenessPassed, isTrue);
    });

    testWidgets('simulateBlink runs full blink cycle to verification', (tester) async {
      bool livenessPassed = false;
      final key = GlobalKey<LivenessCameraOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LivenessCameraOverlay(
                  key: key,
                  onLivenessPassed: () => livenessPassed = true,
                ),
              ],
            ),
          ),
        ),
      );

      key.currentState?.simulateBlink();
      await tester.pump();
      expect(key.currentState?.currentStep, equals(LivenessStep.promptBlink));

      // Wait for delayed eye close
      await tester.pump(const Duration(milliseconds: 160));
      expect(key.currentState?.eyesWereClosed, isTrue);

      // Wait for delayed eye reopen
      await tester.pump(const Duration(milliseconds: 160));
      expect(key.currentState?.currentStep, equals(LivenessStep.verified));

      // Wait for success callback
      await tester.pump(const Duration(milliseconds: 550));
      expect(livenessPassed, isTrue);
    });

    testWidgets('reset() restores initial waitingForFace state and resets flags', (tester) async {
      final key = GlobalKey<LivenessCameraOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LivenessCameraOverlay(
                  key: key,
                  onLivenessPassed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Progress into promptBlink and close eyes
      key.currentState?.processProbabilities(leftEye: 0.95, rightEye: 0.95);
      key.currentState?.processProbabilities(leftEye: 0.10, rightEye: 0.10);
      await tester.pump();
      expect(key.currentState?.eyesWereClosed, isTrue);

      // Reset
      key.currentState?.reset();
      await tester.pump();

      expect(key.currentState?.currentStep, equals(LivenessStep.waitingForFace));
      expect(key.currentState?.eyesWereClosed, isFalse);
      expect(key.currentState?.leftEyeProbability, isNull);
      expect(key.currentState?.rightEyeProbability, isNull);
      expect(find.text('Position your face in the frame'), findsOneWidget);
    });

    test('MLKitFaceService exposes fastFaceDetector with fast mode and enableClassification: true', () {
      final detector = MLKitFaceService().fastFaceDetector;
      expect(detector.options.enableClassification, isTrue);
      expect(detector.options.performanceMode, equals(FaceDetectorMode.fast));
      expect(detector.options.enableLandmarks, isTrue);
    });
  });
}
