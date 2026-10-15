import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Steps in the real-time biometric liveness state machine
enum LivenessStep {
  waitingForFace,
  promptBlink,
  verified,
}

/// Real-time Liveness Validator Overlay Widget
///
/// Prevents proxy attendance spoofing (printed photo, static screens, video replays)
/// by requiring a living human blink cycle (Eyes Open -> Closed -> Open again)
/// before confirming attendance and auto-triggering biometric verification.
class LivenessCameraOverlay extends StatefulWidget {
  final VoidCallback onLivenessPassed;
  final bool showTelemetry;
  final double bottomOffset;

  const LivenessCameraOverlay({
    super.key,
    required this.onLivenessPassed,
    this.showTelemetry = true,
    this.bottomOffset = 50.0,
  });

  @override
  LivenessCameraOverlayState createState() => LivenessCameraOverlayState();
}

class LivenessCameraOverlayState extends State<LivenessCameraOverlay>
    with SingleTickerProviderStateMixin {
  LivenessStep _currentStep = LivenessStep.waitingForFace;
  bool _eyesWereClosed = false;
  String _instructionText = 'Position your face in the frame';
  double? _leftEyeProb;
  double? _rightEyeProb;
  double? _headAngleY;
  Timer? _verificationDelayTimer;

  // Visual pulse animation for active scanning / blink prompt
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  LivenessStep get currentStep => _currentStep;
  bool get eyesWereClosed => _eyesWereClosed;
  String get instructionText => _instructionText;
  double? get leftEyeProbability => _leftEyeProb;
  double? get rightEyeProbability => _rightEyeProb;
  double? get headAngleY => _headAngleY;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _verificationDelayTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Reset the liveness state machine back to initial state
  void reset() {
    _verificationDelayTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _currentStep = LivenessStep.waitingForFace;
      _eyesWereClosed = false;
      _instructionText = 'Position your face in the frame';
      _leftEyeProb = null;
      _rightEyeProb = null;
      _headAngleY = null;
    });
  }

  /// Process direct probability values (useful for unit testing and computer vision feeds)
  void processProbabilities({
    required double leftEye,
    required double rightEye,
    double? headEulerAngleY,
  }) {
    if (!mounted) return;

    setState(() {
      _leftEyeProb = leftEye;
      _rightEyeProb = rightEye;
      _headAngleY = headEulerAngleY;
    });

    switch (_currentStep) {
      case LivenessStep.waitingForFace:
        // Face found with eyes open, prompt user to blink
        if (leftEye > 0.60 && rightEye > 0.60) {
          setState(() {
            _currentStep = LivenessStep.promptBlink;
            _instructionText = 'Please Blink Your Eyes';
          });
        }
        break;

      case LivenessStep.promptBlink:
        // Check if eyes are closed (probability drops below threshold e.g. < 0.25)
        if (leftEye < 0.25 && rightEye < 0.25) {
          _eyesWereClosed = true;
        }

        // If eyes were confirmed closed and are now open again (> 0.70), blink is complete!
        if (_eyesWereClosed && (leftEye > 0.70 && rightEye > 0.70)) {
          setState(() {
            _currentStep = LivenessStep.verified;
            _instructionText = 'Liveness Verified! Capturing...';
          });

          // Trigger success callback after a brief delay
          _verificationDelayTimer?.cancel();
          _verificationDelayTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onLivenessPassed();
            }
          });
        }
        break;

      case LivenessStep.verified:
        // Already verified, do nothing
        break;
    }
  }

  /// Call this function for each frame processed from your camera stream
  void processCameraFace(Face face) {
    final double? leftEye = face.leftEyeOpenProbability;
    final double? rightEye = face.rightEyeOpenProbability;

    // If probabilities are null, classifications aren't ready yet
    if (leftEye == null || rightEye == null) return;

    processProbabilities(
      leftEye: leftEye,
      rightEye: rightEye,
      headEulerAngleY: face.headEulerAngleY,
    );
  }

  /// Simulate a human blink cycle for testing or debug environments
  void simulateBlink() {
    // 1. Initial face detected
    processProbabilities(leftEye: 0.95, rightEye: 0.95);

    // 2. Eyes closed during blink
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        processProbabilities(leftEye: 0.10, rightEye: 0.10);
      }
    });

    // 3. Eyes reopen to complete the blink cycle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        processProbabilities(leftEye: 0.92, rightEye: 0.94);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;

    switch (_currentStep) {
      case LivenessStep.waitingForFace:
        badgeColor = Colors.black87;
        badgeIcon = Icons.visibility_outlined;
        break;
      case LivenessStep.promptBlink:
        badgeColor = const Color(0xFFD97706); // Amber prompt
        badgeIcon = Icons.remove_red_eye_outlined;
        break;
      case LivenessStep.verified:
        badgeColor = const Color(0xFF10B981); // Emerald green verified
        badgeIcon = Icons.check_circle;
        break;
    }

    return Positioned(
      bottom: widget.bottomOffset,
      left: 20,
      right: 20,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Anti-Proxy Liveness Indicator Pill
            ScaleTransition(
              scale: _currentStep == LivenessStep.promptBlink
                  ? _pulseAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      badgeIcon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _instructionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Live Eye Probability Telemetry Chip (shows anti-spoof sensor values)
            if (widget.showTelemetry &&
                (_leftEyeProb != null || _rightEyeProb != null)) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 11,
                      color: Color(0xFF6EE7B7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Anti-Proxy: L ${((_leftEyeProb ?? 0.0) * 100).toInt()}% • R ${((_rightEyeProb ?? 0.0) * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (_eyesWereClosed) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'BLINK OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
