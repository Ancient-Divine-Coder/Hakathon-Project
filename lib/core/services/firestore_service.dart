import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../features/attendance/presentation/attendance_history_screen.dart';
import 'staff_attendance_service.dart';

/// Service for handling Cloud Firestore operations and connectivity verification
/// for the Smart Campus ERP application.
class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  /// Default constructor with optional injected instance (useful for testing/mocking).
  FirestoreService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  /// Expose Firestore instance if direct access is needed
  FirebaseFirestore get firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  /// Records an attendance check-in/check-out entry directly into 'attendance_history'.
  Future<String?> recordAttendance({
    required String employeeId,
    required String dateTitle,
    required String inTime,
    String outTime = '--:--',
    String totalHours = 'In Progress',
    String statusLabel = 'Biometric Verified',
    String gateTurnstile = 'Turnstile Gate A-12 • Main Academic Block',
    String sessionSubtitle = 'Academic Duty • Smart Biometric Sync',
    bool isRegular = true,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? distanceMeters,
    String? geofenceStatus,
    double? faceMatchScore,
  }) async {
    final entry = AttendanceLogEntry(
      dateTitle: dateTitle,
      location: gateTurnstile,
      category: isRegular ? 'present' : 'irregular',
      badgeText: statusLabel,
      badgeIcon: Icons.fingerprint,
      checkIn: inTime,
      checkOut: outTime,
      duration: totalHours,
      subnote: sessionSubtitle,
      isLive: outTime == '--:--' || outTime == 'In Progress',
    );
    StaffAttendanceService().recordLocalAttendance(entry, employeeId);

    if (Firebase.apps.isEmpty) {
      return 'mock_offline_id_${DateTime.now().millisecondsSinceEpoch}';
    }
    try {
      final payload = <String, dynamic>{
        'employeeId': employeeId,
        'dateTitle': dateTitle,
        'inTime': inTime,
        'outTime': outTime,
        'totalHours': totalHours,
        'statusLabel': statusLabel,
        'gateTurnstile': gateTurnstile,
        'sessionSubtitle': sessionSubtitle,
        'isRegular': isRegular,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (latitude != null) payload['latitude'] = latitude;
      if (longitude != null) payload['longitude'] = longitude;
      if (accuracyMeters != null) payload['accuracyMeters'] = accuracyMeters;
      if (distanceMeters != null) payload['distanceMeters'] = distanceMeters;
      if (geofenceStatus != null) payload['geofenceStatus'] = geofenceStatus;
      if (faceMatchScore != null) payload['faceMatchScore'] = faceMatchScore;

      final docId = await addRecord(
        collectionPath: 'attendance_history',
        data: payload,
      );
      return docId;
    } catch (_) {
      return null;
    }
  }

  /// Add a new record with an auto-generated Document ID.
  Future<String> addRecord({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await firestore.collection(collectionPath).add({
      ...data,
      'createdAt': data.containsKey('createdAt')
          ? data['createdAt']
          : FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Create or overwrite a record with a specific Document ID.
  Future<void> setRecord({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await firestore.collection(collectionPath).doc(documentId).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: merge),
    );
  }

  /// Retrieve a single record by its Document ID.
  Future<Map<String, dynamic>?> getRecord({
    required String collectionPath,
    required String documentId,
  }) async {
    final snapshot =
        await firestore.collection(collectionPath).doc(documentId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    final data = snapshot.data()!;
    return {
      'id': snapshot.id,
      ...data,
    };
  }

  /// Update an existing record.
  Future<void> updateRecord({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collectionPath).doc(documentId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a record by its Document ID.
  Future<void> deleteRecord({
    required String collectionPath,
    required String documentId,
  }) async {
    await firestore.collection(collectionPath).doc(documentId).delete();
  }

  /// Fetch all records in a collection as a one-time Future.
  Future<List<Map<String, dynamic>>> getCollection({
    required String collectionPath,
    int? limit,
  }) async {
    Query query = firestore.collection(collectionPath);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...(doc.data() as Map<String, dynamic>),
      };
    }).toList();
  }

  /// Real-time stream of all records in a collection.
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collectionPath,
    int? limit,
  }) {
    try {
      Query query = firestore.collection(collectionPath);
      if (limit != null) {
        query = query.limit(limit);
      }
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...(doc.data() as Map<String, dynamic>),
          };
        }).toList();
      });
    } catch (e, stack) {
      return Stream.error(e, stack);
    }
  }

  /// Real-time stream of a single record.
  Stream<Map<String, dynamic>?> streamRecord({
    required String collectionPath,
    required String documentId,
  }) {
    try {
      return firestore
          .collection(collectionPath)
          .doc(documentId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return null;
        }
        return {
          'id': snapshot.id,
          ...snapshot.data()!,
        };
      });
    } catch (e, stack) {
      return Stream.error(e, stack);
    }
  }

  /// Diagnostic method that tests writing, reading, and updating a record in Firestore.
  ///
  /// Returns a detailed diagnostic result map containing latency and verification status.
  Future<Map<String, dynamic>> testReadWriteCycle({
    String collection = 'connectivity_tests',
  }) async {
    final startTime = DateTime.now();
    final testId = 'test_${DateTime.now().millisecondsSinceEpoch}';
    final samplePayload = {
      'testId': testId,
      'app': 'Campus ERP',
      'purpose': 'Firestore Connectivity & Read/Write Verification',
      'status': 'initial_write',
      'deviceTimestamp': startTime.toIso8601String(),
    };

    // 1. Test Write
    final writeStopwatch = Stopwatch()..start();
    await firestore.collection(collection).doc(testId).set({
      ...samplePayload,
      'createdAt': FieldValue.serverTimestamp(),
    });
    writeStopwatch.stop();

    // 2. Test Read
    final readStopwatch = Stopwatch()..start();
    final readSnapshot =
        await firestore.collection(collection).doc(testId).get();
    readStopwatch.stop();

    if (!readSnapshot.exists) {
      throw StateError(
          'Verification failed: Document $testId was written but could not be read back.');
    }

    final readData = readSnapshot.data() ?? {};

    // 3. Test Update
    final updateStopwatch = Stopwatch()..start();
    await firestore.collection(collection).doc(testId).update({
      'status': 'verified_read_write_success',
      'verifiedAt': FieldValue.serverTimestamp(),
    });
    updateStopwatch.stop();

    final totalElapsedMs =
        DateTime.now().difference(startTime).inMilliseconds;

    return {
      'success': true,
      'testId': testId,
      'collection': collection,
      'writeLatencyMs': writeStopwatch.elapsedMilliseconds,
      'readLatencyMs': readStopwatch.elapsedMilliseconds,
      'updateLatencyMs': updateStopwatch.elapsedMilliseconds,
      'totalDurationMs': totalElapsedMs,
      'readData': readData,
    };
  }
}
