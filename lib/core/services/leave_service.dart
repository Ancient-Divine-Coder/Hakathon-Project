import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../features/leave/domain/models/leave_application.dart';
import '../../features/leave/domain/models/leave_balance.dart';

/// Central service for managing leave balances, applications, and sanctions
/// across faculty and staff profiles in the Smart Campus ERP.
class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();

  /// In-memory cache of leave balances keyed by uppercase employeeId
  final Map<String, LeaveBalance> _balances = {};

  /// In-memory cache of leave applications keyed by uppercase employeeId
  final Map<String, List<LeaveApplication>> _applications = {};

  /// Baseline benchmark applications for Dr. Rajesh Sharma (FAC-2024-CS01 / CS-4092)
  List<LeaveApplication> get _defaultRajeshSharmaApplications => [
        LeaveApplication(
          id: 'LV-2024-001',
          employeeId: 'FAC-2024-CS01',
          applicantName: 'Dr. Rajesh Sharma',
          department: 'Computer Science & Engineering',
          leaveType: LeaveType.onDuty,
          startDate: DateTime(2024, 10, 18),
          endDate: DateTime(2024, 10, 18),
          totalDays: 1.0,
          reason: 'IEEE International Conference on AI in Higher Education (Keynote Speaker)',
          status: LeaveStatus.approved,
          appliedAt: DateTime(2024, 10, 10),
          approvedBy: 'Prof. A. K. Verma (Dean Academics)',
          reviewedAt: DateTime(2024, 10, 12),
          rejectionReason: null,
          attachmentUrl: 'sanction_ref_OD_2024_094.pdf',
        ),
        LeaveApplication(
          id: 'LV-2024-002',
          employeeId: 'FAC-2024-CS01',
          applicantName: 'Dr. Rajesh Sharma',
          department: 'Computer Science & Engineering',
          leaveType: LeaveType.casual,
          startDate: DateTime(2024, 10, 4),
          endDate: DateTime(2024, 10, 4),
          totalDays: 1.0,
          reason: 'Personal family engagement & academic consultation',
          status: LeaveStatus.approved,
          appliedAt: DateTime(2024, 10, 1),
          approvedBy: 'HOD, Computer Science',
          reviewedAt: DateTime(2024, 10, 2),
        ),
        LeaveApplication(
          id: 'LV-2024-003',
          employeeId: 'FAC-2024-CS01',
          applicantName: 'Dr. Rajesh Sharma',
          department: 'Computer Science & Engineering',
          leaveType: LeaveType.onDuty,
          startDate: DateTime(2024, 10, 28),
          endDate: DateTime(2024, 10, 29),
          totalDays: 2.0,
          reason: 'State University Curriculum Revision Committee Member meeting',
          status: LeaveStatus.pending,
          appliedAt: DateTime(2024, 10, 22),
        ),
      ];

  /// Benchmark applications for Prof. Vikram Malhotra
  List<LeaveApplication> get _defaultVikramMalhotraApplications => [
        LeaveApplication(
          id: 'LV-2024-004',
          employeeId: 'SKIT-FAC-2024-7719',
          applicantName: 'Prof. Vikram Malhotra',
          department: 'Electronics & Comm',
          leaveType: LeaveType.casual,
          startDate: DateTime(2024, 10, 25),
          endDate: DateTime(2024, 10, 25),
          totalDays: 1.0,
          reason: 'Specialist medical consultation & diagnostic testing',
          status: LeaveStatus.pending,
          appliedAt: DateTime(2024, 10, 23),
        ),
      ];

  /// Benchmark applications for Dr. Ananya Pandey
  List<LeaveApplication> get _defaultAnanyaPandeyApplications => [
        LeaveApplication(
          id: 'LV-2024-005',
          employeeId: 'SKIT-FAC-2024-9102',
          applicantName: 'Dr. Ananya Pandey',
          department: 'Mechanical Engg',
          leaveType: LeaveType.onDuty,
          startDate: DateTime(2024, 10, 30),
          endDate: DateTime(2024, 10, 31),
          totalDays: 2.0,
          reason: 'National Robotics & Automation Symposium paper presentation',
          status: LeaveStatus.pending,
          appliedAt: DateTime(2024, 10, 21),
          attachmentUrl: 'symposium_invitation_letter.pdf',
        ),
      ];

  /// Benchmark applications for Dr. Harish Chandra (Disapproved record)
  List<LeaveApplication> get _defaultHarishChandraApplications => [
        LeaveApplication(
          id: 'LV-2024-006',
          employeeId: 'SKIT-FAC-2024-6330',
          applicantName: 'Dr. Harish Chandra',
          department: 'Civil Engineering',
          leaveType: LeaveType.casual,
          startDate: DateTime(2024, 10, 12),
          endDate: DateTime(2024, 10, 13),
          totalDays: 2.0,
          reason: 'Personal travel during mid-semester examination duty',
          status: LeaveStatus.rejected,
          appliedAt: DateTime(2024, 10, 8),
          approvedBy: 'Prof. A. K. Verma (Dean Academics)',
          reviewedAt: DateTime(2024, 10, 9),
          rejectionReason: 'Leave disapproved due to scheduled mid-term exam invigilation slot.',
        ),
      ];

  /// Retrieve the current leave balance for [employeeId]
  LeaveBalance getLeaveBalance(String employeeId) {
    final cleanId = employeeId.trim().toUpperCase();
    if (_balances.containsKey(cleanId)) {
      return _balances[cleanId]!;
    }

    if (cleanId == 'FAC-2024-CS01' || cleanId == 'CS-4092' || cleanId.isEmpty) {
      const benchmark = LeaveBalance(
        employeeId: 'FAC-2024-CS01',
        academicYear: 2024,
        casualLeaveTotal: 12.0,
        casualLeaveUsed: 3.0,
        medicalLeaveTotal: 10.0,
        medicalLeaveUsed: 1.0,
        onDutyLeaveUsed: 2.0,
        earnedLeaveTotal: 15.0,
        earnedLeaveUsed: 0.0,
        compOffBalance: 2.0,
      );
      _balances[cleanId] = benchmark;
      return benchmark;
    }

    // New faculty member: full annual quota with 0 utilized
    final newBalance = LeaveBalance(
      employeeId: employeeId.trim(),
      academicYear: 2024,
      casualLeaveTotal: 12.0,
      casualLeaveUsed: 0.0,
      medicalLeaveTotal: 10.0,
      medicalLeaveUsed: 0.0,
      onDutyLeaveUsed: 0.0,
      earnedLeaveTotal: 15.0,
      earnedLeaveUsed: 0.0,
      compOffBalance: 0.0,
    );
    _balances[cleanId] = newBalance;
    return newBalance;
  }

  /// Retrieve all leave applications for [employeeId]
  List<LeaveApplication> getLeaveApplications(String employeeId) {
    final cleanId = employeeId.trim().toUpperCase();
    if (_applications.containsKey(cleanId)) {
      return _applications[cleanId]!;
    }

    if (cleanId == 'FAC-2024-CS01' || cleanId == 'CS-4092' || cleanId.isEmpty) {
      final list = List<LeaveApplication>.from(_defaultRajeshSharmaApplications);
      _applications[cleanId] = list;
      return list;
    }

    if (cleanId == 'SKIT-FAC-2024-7719' || cleanId == 'FAC-2024-EC04') {
      final list = List<LeaveApplication>.from(_defaultVikramMalhotraApplications);
      _applications[cleanId] = list;
      return list;
    }

    if (cleanId == 'SKIT-FAC-2024-9102') {
      final list = List<LeaveApplication>.from(_defaultAnanyaPandeyApplications);
      _applications[cleanId] = list;
      return list;
    }

    if (cleanId == 'SKIT-FAC-2024-6330') {
      final list = List<LeaveApplication>.from(_defaultHarishChandraApplications);
      _applications[cleanId] = list;
      return list;
    }

    _applications[cleanId] = [];
    return [];
  }

  /// Retrieve all leave applications across all campus staff for admin review
  List<LeaveApplication> getAllApplications() {
    // Seed default datasets if not already accessed
    getLeaveApplications('FAC-2024-CS01');
    getLeaveApplications('SKIT-FAC-2024-7719');
    getLeaveApplications('SKIT-FAC-2024-9102');
    getLeaveApplications('SKIT-FAC-2024-6330');

    final all = <LeaveApplication>[];
    for (final list in _applications.values) {
      all.addAll(list);
    }
    all.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return all;
  }

  /// Retrieve only pending applications requiring administrative clearance
  List<LeaveApplication> getPendingApplications() {
    return getAllApplications()
        .where((app) => app.status == LeaveStatus.pending)
        .toList();
  }

  /// Admin approves a faculty leave application
  Future<bool> approveLeaveApplication({
    required String applicationId,
    required String reviewerName,
    String? remarks,
  }) async {
    // Ensure all applications are loaded
    getAllApplications();

    LeaveApplication? targetApp;
    for (final entry in _applications.entries) {
      final idx = entry.value.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        targetApp = entry.value[idx];
        final updatedApp = targetApp.copyWith(
          status: LeaveStatus.approved,
          approvedBy: reviewerName,
          reviewedAt: DateTime.now(),
        );
        entry.value[idx] = updatedApp;
        break;
      }
    }

    if (targetApp == null) return false;

    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('leave_applications')
            .doc(applicationId)
            .update({
          'status': 'approved',
          'approvedBy': reviewerName,
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('[LeaveService] Error updating approved status in Firestore: $e');
      }
    }
    return true;
  }

  /// Admin rejects a faculty leave application and restores their quota
  Future<bool> rejectLeaveApplication({
    required String applicationId,
    required String reviewerName,
    required String rejectionReason,
  }) async {
    // Ensure all applications are loaded
    getAllApplications();

    LeaveApplication? targetApp;
    for (final entry in _applications.entries) {
      final idx = entry.value.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        targetApp = entry.value[idx];
        final updatedApp = targetApp.copyWith(
          status: LeaveStatus.rejected,
          approvedBy: reviewerName,
          rejectionReason: rejectionReason,
          reviewedAt: DateTime.now(),
        );
        entry.value[idx] = updatedApp;
        break;
      }
    }

    if (targetApp == null) return false;

    // Restore deducted quota to the faculty member
    final cleanId = targetApp.employeeId.trim().toUpperCase();
    final balance = getLeaveBalance(targetApp.employeeId);
    LeaveBalance restoredBalance = balance;
    switch (targetApp.leaveType) {
      case LeaveType.casual:
        restoredBalance = balance.copyWith(
          casualLeaveUsed: (balance.casualLeaveUsed - targetApp.totalDays).clamp(0.0, 99.0),
        );
        break;
      case LeaveType.medical:
        restoredBalance = balance.copyWith(
          medicalLeaveUsed: (balance.medicalLeaveUsed - targetApp.totalDays).clamp(0.0, 99.0),
        );
        break;
      case LeaveType.onDuty:
        restoredBalance = balance.copyWith(
          onDutyLeaveUsed: (balance.onDutyLeaveUsed - targetApp.totalDays).clamp(0.0, 99.0),
        );
        break;
      case LeaveType.earned:
        restoredBalance = balance.copyWith(
          earnedLeaveUsed: (balance.earnedLeaveUsed - targetApp.totalDays).clamp(0.0, 99.0),
        );
        break;
      case LeaveType.compensatory:
        restoredBalance = balance.copyWith(
          compOffBalance: balance.compOffBalance + targetApp.totalDays,
        );
        break;
    }
    _balances[cleanId] = restoredBalance;

    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('leave_applications')
            .doc(applicationId)
            .update({
          'status': 'rejected',
          'approvedBy': reviewerName,
          'rejectionReason': rejectionReason,
          'reviewedAt': FieldValue.serverTimestamp(),
        });

        await firestore
            .collection('leave_balances')
            .doc(cleanId)
            .set(restoredBalance.toMap());
      } catch (e) {
        debugPrint('[LeaveService] Error updating rejected status in Firestore: $e');
      }
    }
    return true;
  }

  /// Submit a new leave application and deduct/update the user's balance
  Future<void> submitLeaveApplication(LeaveApplication application) async {
    final cleanId = application.employeeId.trim().toUpperCase();
    final list = _applications[cleanId] != null
        ? List<LeaveApplication>.from(_applications[cleanId]!)
        : getLeaveApplications(application.employeeId);

    list.insert(0, application);
    _applications[cleanId] = list;

    // Deduct from balance
    final balance = getLeaveBalance(application.employeeId);
    LeaveBalance updatedBalance = balance;
    switch (application.leaveType) {
      case LeaveType.casual:
        updatedBalance = balance.copyWith(
          casualLeaveUsed: balance.casualLeaveUsed + application.totalDays,
        );
        break;
      case LeaveType.medical:
        updatedBalance = balance.copyWith(
          medicalLeaveUsed: balance.medicalLeaveUsed + application.totalDays,
        );
        break;
      case LeaveType.onDuty:
        updatedBalance = balance.copyWith(
          onDutyLeaveUsed: balance.onDutyLeaveUsed + application.totalDays,
        );
        break;
      case LeaveType.earned:
        updatedBalance = balance.copyWith(
          earnedLeaveUsed: balance.earnedLeaveUsed + application.totalDays,
        );
        break;
      case LeaveType.compensatory:
        updatedBalance = balance.copyWith(
          compOffBalance: (balance.compOffBalance - application.totalDays).clamp(0.0, 99.0),
        );
        break;
    }
    _balances[cleanId] = updatedBalance;

    // Persist to Firestore if available
    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('leave_applications')
            .doc(application.id)
            .set(application.toMap());

        await firestore
            .collection('leave_balances')
            .doc(cleanId)
            .set(updatedBalance.toMap());
      } catch (e) {
        debugPrint('[LeaveService] Error persisting application to Firestore: $e');
      }
    }
  }

  /// Cancel a pending leave application and restore the balance
  Future<void> cancelLeaveApplication(String applicationId, String employeeId) async {
    final cleanId = employeeId.trim().toUpperCase();
    final list = _applications[cleanId] != null
        ? List<LeaveApplication>.from(_applications[cleanId]!)
        : getLeaveApplications(employeeId);

    final idx = list.indexWhere((app) => app.id == applicationId);
    if (idx != -1) {
      final app = list[idx];
      if (app.status == LeaveStatus.pending) {
        list[idx] = app.copyWith(status: LeaveStatus.cancelled);
        _applications[cleanId] = list;

        // Restore balance
        final balance = getLeaveBalance(employeeId);
        LeaveBalance updatedBalance = balance;
        switch (app.leaveType) {
          case LeaveType.casual:
            updatedBalance = balance.copyWith(
              casualLeaveUsed: (balance.casualLeaveUsed - app.totalDays).clamp(0.0, 99.0),
            );
            break;
          case LeaveType.medical:
            updatedBalance = balance.copyWith(
              medicalLeaveUsed: (balance.medicalLeaveUsed - app.totalDays).clamp(0.0, 99.0),
            );
            break;
          case LeaveType.onDuty:
            updatedBalance = balance.copyWith(
              onDutyLeaveUsed: (balance.onDutyLeaveUsed - app.totalDays).clamp(0.0, 99.0),
            );
            break;
          case LeaveType.earned:
            updatedBalance = balance.copyWith(
              earnedLeaveUsed: (balance.earnedLeaveUsed - app.totalDays).clamp(0.0, 99.0),
            );
            break;
          case LeaveType.compensatory:
            updatedBalance = balance.copyWith(
              compOffBalance: balance.compOffBalance + app.totalDays,
            );
            break;
        }
        _balances[cleanId] = updatedBalance;

        if (Firebase.apps.isNotEmpty) {
          try {
            await FirebaseFirestore.instance
                .collection('leave_applications')
                .doc(applicationId)
                .update({'status': 'cancelled'});
          } catch (e) {
            debugPrint('[LeaveService] Error updating cancelled status in Firestore: $e');
          }
        }
      }
    }
  }
}
