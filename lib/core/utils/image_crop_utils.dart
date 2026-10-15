import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Holds both the circular-alpha PNG and square JPEG versions of a reticle-cropped image.
class CircularCropResult {
  /// PNG image bytes with transparent background outside the circular reticle.
  final Uint8List circularPngBytes;

  /// Square JPEG image bytes representing the 1:1 inscribed box of the circular viewfinder.
  final Uint8List squareJpgBytes;

  /// Width / Height in pixels.
  final int dimension;

  const CircularCropResult({
    required this.circularPngBytes,
    required this.squareJpgBytes,
    required this.dimension,
  });
}

/// Utility for cropping raw camera frames to precisely align with the circular
/// viewfinder grid and face alignment reticle.
class ImageCropUtils {
  /// Crops an incoming camera frame (landscape or portrait) to the exact 1:1
  /// region visible within the circular viewfinder, and masks the outer boundary
  /// with an antialiased circular alpha channel.
  static CircularCropResult cropToCircularGrid(
    Uint8List rawBytes, {
    int maxDimension = 512,
  }) {
    try {
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        return CircularCropResult(
          circularPngBytes: rawBytes,
          squareJpgBytes: rawBytes,
          dimension: 0,
        );
      }

      // Bake EXIF orientation if available
      final oriented = img.bakeOrientation(decoded);

      // Viewfinder uses BoxFit.cover inside a 1:1 circular container.
      // The visible area corresponds precisely to the center-aligned square
      // with side equal to min(width, height).
      final side = math.min(oriented.width, oriented.height);
      final cropX = (oriented.width - side) ~/ 2;
      final cropY = (oriented.height - side) ~/ 2;

      final squareImg = img.copyCrop(
        oriented,
        x: cropX,
        y: cropY,
        width: side,
        height: side,
      );

      // Resize for performance and crisp display
      final targetSide = side > maxDimension ? maxDimension : side;
      final resizedSquare = side > maxDimension
          ? img.copyResize(squareImg, width: targetSide, height: targetSide)
          : squareImg;

      // Create an RGBA (4-channel) copy for the circular alpha mask
      final circularImg = resizedSquare.convert(numChannels: 4);

      final center = targetSide / 2.0;
      final radius = targetSide / 2.0;
      final radiusSq = radius * radius;
      final innerRadius = radius - 1.5;
      final innerRadiusSq = innerRadius * innerRadius;

      for (int y = 0; y < targetSide; y++) {
        for (int x = 0; x < targetSide; x++) {
          final dx = x - center + 0.5;
          final dy = y - center + 0.5;
          final distSq = dx * dx + dy * dy;

          final pixel = circularImg.getPixel(x, y);

          if (distSq > radiusSq) {
            // Outside circle -> transparent
            pixel.a = 0;
          } else if (distSq > innerRadiusSq) {
            // Antialiased transition border
            final dist = math.sqrt(distSq);
            final alphaFraction = (radius - dist).clamp(0.0, 1.0);
            pixel.a = (pixel.a * alphaFraction).round();
          }
        }
      }

      final pngBytes = Uint8List.fromList(img.encodePng(circularImg));
      final jpgBytes = Uint8List.fromList(img.encodeJpg(resizedSquare, quality: 92));

      return CircularCropResult(
        circularPngBytes: pngBytes,
        squareJpgBytes: jpgBytes,
        dimension: targetSide,
      );
    } catch (_) {
      return CircularCropResult(
        circularPngBytes: rawBytes,
        squareJpgBytes: rawBytes,
        dimension: 0,
      );
    }
  }
}
