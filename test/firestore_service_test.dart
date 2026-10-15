import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:campus_erp/core/services/firestore_service.dart';
import 'package:campus_erp/features/firestore_test/presentation/firestore_test_screen.dart';

void main() {
  group('FirestoreService Initialization & APIs', () {
    test('FirestoreService constructor instantiates cleanly', () {
      final service = FirestoreService();
      expect(service, isNotNull);
    });
  });

  group('FirestoreTestScreen UI Component Tests', () {
    testWidgets('Renders diagnostic button, write section, and stream section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FirestoreTestScreen(),
        ),
      );
      await tester.pump();

      // Verify header and project badge
      expect(find.text('Firestore Service & Database Test'), findsOneWidget);
      expect(find.text('Project: college-5efe7'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);

      // Verify action buttons and section labels
      expect(find.text('Run Read & Write Diagnostic Test'), findsOneWidget);
      expect(find.text('Write Record to Firestore'), findsOneWidget);
      expect(find.text('Read Single Record by ID'), findsOneWidget);
      expect(find.text('Live Collection Stream'), findsOneWidget);
    });
  });
}
