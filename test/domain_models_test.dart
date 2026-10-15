import 'package:flutter_test/flutter_test.dart';
import 'package:campus_erp/core/models/models.dart';
import 'package:campus_erp/core/services/auth_service.dart';

void main() {
  group('Domain Models Tests', () {
    test('UserRole serialization and helpers', () {
      expect(UserRole.faculty.displayName, 'Faculty');
      expect(UserRole.admin.displayName, 'Administrator');
      expect(UserRoleExtension.fromString('admin'), UserRole.admin);
      expect(UserRoleExtension.fromString('faculty'), UserRole.faculty);
      expect(UserRoleExtension.fromString(null), UserRole.faculty);
    });

    test('FacultyProfile serialization and copyWith', () {
      final profile = FacultyProfile.demoProfile;
      final map = profile.toMap();

      expect(map['employeeId'], 'SKIT-FAC-2024-8841');
      expect(map['name'], 'Dr. Rajesh Sharma');

      final reconstructed = FacultyProfile.fromMap(map);
      expect(reconstructed.name, profile.name);
      expect(reconstructed.department, profile.department);

      final updated = profile.copyWith(cabinNumber: 'TW-505');
      expect(updated.cabinNumber, 'TW-505');
      expect(updated.name, profile.name);
    });

    test('AttendanceLogEntry serialization', () {
      const entry = AttendanceLogEntry(
        dateTitle: 'Today, 24 Oct',
        sessionSubtitle: 'General Duty Shift',
        inTime: '08:55 AM',
        outTime: '04:30 PM',
        totalHours: '7h 35m',
        statusLabel: 'On Time',
        gateTurnstile: 'Gate A-12',
      );

      final map = entry.toMap();
      final fromMap = AttendanceLogEntry.fromMap(map);

      expect(fromMap.dateTitle, 'Today, 24 Oct');
      expect(fromMap.isRegular, true);
    });

    test('DailyAttendanceStatus serialization', () {
      const status = DailyAttendanceStatus(
        date: '2024-10-24',
        status: DutyStatus.onDuty,
        checkInTime: '08:55 AM',
        expectedCheckOutTime: '04:30 PM',
        isOnTime: true,
      );

      final map = status.toMap();
      final fromMap = DailyAttendanceStatus.fromMap(map);

      expect(fromMap.date, '2024-10-24');
      expect(fromMap.status, DutyStatus.onDuty);
      expect(fromMap.isOnTime, true);
    });

    test('MonthlyOverviewStats serialization', () {
      const stats = MonthlyOverviewStats(
        monthLabel: 'Oct 2024',
        attendanceRate: '96.2%',
        daysPresent: 21,
        totalWorkingDays: 22,
      );

      final map = stats.toMap();
      final fromMap = MonthlyOverviewStats.fromMap(map);

      expect(fromMap.monthLabel, 'Oct 2024');
      expect(fromMap.daysPresent, 21);
      expect(fromMap.totalWorkingDays, 22);
    });

    test('BiometricVerificationResult serialization', () {
      final now = DateTime.now();
      final result = BiometricVerificationResult(
        id: 'ver_001',
        facultyId: 'fac_001',
        mode: VerificationMode.facial,
        timestamp: now,
        confidenceScore: 98.7,
        isLivenessPassed: true,
        isMatch: true,
      );

      final map = result.toMap();
      final fromMap = BiometricVerificationResult.fromMap(map);

      expect(fromMap.id, 'ver_001');
      expect(fromMap.mode, VerificationMode.facial);
      expect(fromMap.confidenceScore, 98.7);
      expect(fromMap.isMatch, true);
    });

    test('StaffAttendanceRecord serialization', () {
      const record = StaffAttendanceRecord(
        id: 'SKIT-FAC-2024-8841',
        name: 'Dr. Rajesh Sharma',
        designation: 'Head of Department',
        department: 'Computer Science',
        category: 'teaching',
        checkInTime: '08:55 AM',
        location: 'Turing Block',
        isInsideGeofence: true,
        wifiNetwork: 'SKIT-Campus-5G',
        status: StaffAttendanceStatus.verified,
        method: 'Face & GPS',
      );

      final map = record.toMap();
      final fromMap = StaffAttendanceRecord.fromMap(map);

      expect(fromMap.id, 'SKIT-FAC-2024-8841');
      expect(fromMap.status, StaffAttendanceStatus.verified);
      expect(fromMap.isInsideGeofence, true);
    });

    test('FacultyMember directory model serialization', () {
      const member = FacultyMember(
        id: 'dir_001',
        name: 'Dr. Rajesh Sharma',
        designation: 'Professor & HOD',
        department: 'Computer Science',
        cabin: 'TW-402',
        email: 'rajesh@skit.ac.in',
        phoneExtension: '4401',
        status: FacultyStatus.inCabin,
        subjects: ['Advanced Algorithms', 'Distributed Systems'],
        officeHours: '10:00 AM - 12:00 PM',
      );

      final map = member.toMap();
      final fromMap = FacultyMember.fromMap(map);

      expect(fromMap.id, 'dir_001');
      expect(fromMap.status, FacultyStatus.inCabin);
      expect(fromMap.subjects.length, 2);
    });

    test('LeaveApplication and LeaveBalance calculations', () {
      final now = DateTime.now();
      final app = LeaveApplication(
        id: 'leave_101',
        employeeId: 'SKIT-FAC-2024-8841',
        applicantName: 'Dr. Rajesh Sharma',
        department: 'Computer Science',
        leaveType: LeaveType.casual,
        startDate: now,
        endDate: now.add(const Duration(days: 2)),
        totalDays: 2.0,
        reason: 'Personal engagement',
        appliedAt: now,
      );

      final map = app.toMap();
      final fromMap = LeaveApplication.fromMap(map);

      expect(fromMap.id, 'leave_101');
      expect(fromMap.leaveType, LeaveType.casual);
      expect(fromMap.status, LeaveStatus.pending);

      const balance = LeaveBalance(
        employeeId: 'SKIT-FAC-2024-8841',
        casualLeaveTotal: 12.0,
        casualLeaveUsed: 3.0,
        medicalLeaveTotal: 10.0,
        medicalLeaveUsed: 1.0,
      );

      expect(balance.casualLeaveRemaining, 9.0);
      expect(balance.medicalLeaveRemaining, 9.0);
    });

    test('AuthUser serialization with photoBase64 and credentials', () {
      final user = AuthUser.fromMap('user_fac_99', {
        'name': 'Dr. Ananya Mukherjee',
        'email': 'ananya.m@campus.edu',
        'employeeId': 'SKIT-FAC-2024-8841',
        'role': 'faculty',
        'department': 'Computer Science & Engg',
        'designation': 'Associate Professor',
        'photoBase64':
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      });

      expect(user.name, 'Dr. Ananya Mukherjee');
      expect(user.role, 'faculty');
      expect(user.photoBase64, isNotNull);
      expect(user.photoBase64!.isNotEmpty, true);
    });
  });
}
