import 'package:campus_erp/core/services/face_matching_service.dart';
import 'package:campus_erp/core/services/strict_face_recognition_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('StrictFaceRecognitionService Deep Learning Embedding Tests', () {
    test('getFaceEmbeddingFromBytes extracts a 192-dimensional embedding vector', () async {
      final sampleImg = img.Image(width: 96, height: 96);
      for (int y = 0; y < 96; y++) {
        for (int x = 0; x < 96; x++) {
          sampleImg.setPixelRgb(x, y, 150, 180, 210);
        }
      }
      final rawBytes = img.encodeJpg(sampleImg);

      final embedding = await StrictFaceRecognitionService.getFaceEmbeddingFromBytes(rawBytes);

      expect(embedding, isNotNull);
      expect(embedding!.length, equals(192));
    });

    test('compareEmbeddings returns 100.0% for identical embedding vectors', () {
      final emb = List<double>.generate(192, (i) => (i + 1) / 192.0);

      final similarity = StrictFaceRecognitionService.compareEmbeddings(emb, emb);

      expect(similarity, closeTo(100.0, 0.01));
    });

    test('compareEmbeddings returns 0.0 for empty or mismatched vectors', () {
      final emb1 = List<double>.generate(192, (i) => 1.0);
      final emb2 = List<double>.generate(100, (i) => 1.0);

      expect(StrictFaceRecognitionService.compareEmbeddings(emb1, []), equals(0.0));
      expect(StrictFaceRecognitionService.compareEmbeddings([], emb1), equals(0.0));
      expect(StrictFaceRecognitionService.compareEmbeddings(emb1, emb2), equals(0.0));
    });

    test('compareEmbeddings rejects distinct opposite patterns with low score (< 70%)', () async {
      // Pattern A: Horizontal gradient
      final imgA = img.Image(width: 80, height: 80);
      for (int y = 0; y < 80; y++) {
        for (int x = 0; x < 80; x++) {
          imgA.setPixelRgb(x, y, x * 3, 0, 0);
        }
      }
      final bytesA = img.encodeJpg(imgA);

      // Pattern B: Checkerboard
      final imgB = img.Image(width: 80, height: 80);
      for (int y = 0; y < 80; y++) {
        for (int x = 0; x < 80; x++) {
          final isCheck = ((x ~/ 10) + (y ~/ 10)) % 2 == 0;
          imgB.setPixelRgb(x, y, isCheck ? 0 : 255, isCheck ? 0 : 255, isCheck ? 0 : 255);
        }
      }
      final bytesB = img.encodeJpg(imgB);

      final embA = await StrictFaceRecognitionService.getFaceEmbeddingFromBytes(bytesA);
      final embB = await StrictFaceRecognitionService.getFaceEmbeddingFromBytes(bytesB);

      expect(embA, isNotNull);
      expect(embB, isNotNull);

      final similarity = StrictFaceRecognitionService.compareEmbeddings(embA!, embB!);

      expect(similarity, lessThan(StrictFaceRecognitionService.defaultStrictThreshold));
    });

    test('FaceMatchingService integrates pre-computed enrolledEmbedding directly', () async {
      final sampleImg = img.Image(width: 80, height: 80);
      for (int y = 0; y < 80; y++) {
        for (int x = 0; x < 80; x++) {
          sampleImg.setPixelRgb(x, y, (160 + (x % 20)), (140 + (y % 15)), 120);
        }
      }
      final bytes = img.encodeJpg(sampleImg);

      final precomputedEmbedding =
          await StrictFaceRecognitionService.getFaceEmbeddingFromBytes(bytes);

      final result = await FaceMatchingService().compareFaces(
        liveBytes: bytes,
        enrolledEmbedding: precomputedEmbedding,
      );

      expect(result.isMatch, isTrue);
      expect(result.cosineSimilarity, isNotNull);
      expect(result.cosineSimilarity!, greaterThanOrEqualTo(80.0));
      expect(result.liveFaceEmbedding, isNotNull);
      expect(result.liveFaceEmbedding!.length, equals(192));
    });
  });
}
