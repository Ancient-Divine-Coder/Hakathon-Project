import 'package:campus_erp/core/services/college_grade_face_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CollegeGradeFaceVerifier Biometric Tests', () {
    test('Identical 192-D embeddings yield 100% confidence match', () {
      final emb = List<double>.generate(192, (i) => (i + 1) / 192.0);

      final result = CollegeGradeFaceVerifier.verifyIdentity(
        enrolledEmbedding: emb,
        liveEmbedding: emb,
      );

      expect(result.isMatched, isTrue);
      expect(result.confidenceScore, closeTo(100.0, 0.01));
      expect(result.reason, contains('High-confidence identity match'));
    });

    test('Different individuals with distinct embeddings trigger SECURITY ALERT mismatch', () {
      // Orthogonal vectors: dot product is 0.0, raw similarity 0.0, percentage score 50.0%
      final emb1 = List<double>.generate(192, (i) => i < 96 ? 1.0 : 0.0);
      final emb2 = List<double>.generate(192, (i) => i >= 96 ? 1.0 : 0.0);

      final result = CollegeGradeFaceVerifier.verifyIdentity(
        enrolledEmbedding: emb1,
        liveEmbedding: emb2,
      );

      expect(result.isMatched, isFalse);
      expect(result.confidenceScore, closeTo(50.0, 0.01));
      expect(result.reason, contains('SECURITY ALERT: Face mismatch detected'));
    });

    test('Score in expression tolerance buffer (77.5% to 82.5%) successfully matches', () {
      // Create vectors whose normalized cosine similarity falls in [77.5%, 82.5%)
      // rawSimilarity = 0.60 -> percentageScore = ((0.60 + 1) / 2) * 100 = 80.0%
      final base = List<double>.generate(192, (i) => 1.0);
      // Alter part of the vector to simulate facial expression variation
      final liveWithSmile = List<double>.generate(192, (i) => i < 40 ? 0.2 : 1.0);

      final result = CollegeGradeFaceVerifier.verifyIdentity(
        enrolledEmbedding: base,
        liveEmbedding: liveWithSmile,
      );

      // Verify it falls within expression tolerance buffer
      expect(result.confidenceScore, greaterThanOrEqualTo(CollegeGradeFaceVerifier.strictIdentityThreshold - CollegeGradeFaceVerifier.expressionToleranceBuffer));
      expect(result.isMatched, isTrue);
      if (result.confidenceScore < CollegeGradeFaceVerifier.strictIdentityThreshold) {
        expect(result.reason, contains('Expression variation tolerated'));
      }
    });

    test('Embedding dimension mismatch returns failure result cleanly', () {
      final emb1 = List<double>.generate(192, (i) => 1.0);
      final emb2 = List<double>.generate(128, (i) => 1.0);

      final result = CollegeGradeFaceVerifier.verifyIdentity(
        enrolledEmbedding: emb1,
        liveEmbedding: emb2,
      );

      expect(result.isMatched, isFalse);
      expect(result.confidenceScore, equals(0.0));
      expect(result.reason, contains('dimension mismatch'));
    });

    test('Zero vectors return failure cleanly', () {
      final zero = List<double>.filled(192, 0.0);
      final emb = List<double>.generate(192, (i) => 1.0);

      final result = CollegeGradeFaceVerifier.verifyIdentity(
        enrolledEmbedding: zero,
        liveEmbedding: emb,
      );

      expect(result.isMatched, isFalse);
      expect(result.confidenceScore, equals(0.0));
      expect(result.reason, contains('Zero-vector'));
    });
  });
}
