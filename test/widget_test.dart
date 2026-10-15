import 'package:campus_erp/features/admin/presentation/admin_leave_approval_screen.dart';
import 'package:campus_erp/features/admin/presentation/campus_attendance_management_screen.dart';
import 'package:campus_erp/features/attendance/presentation/attendance_history_screen.dart';
import 'package:campus_erp/features/attendance/presentation/facial_verification_screen.dart';
import 'package:campus_erp/features/attendance/presentation/mark_attendance_screen.dart';
import 'package:campus_erp/features/dashboard/presentation/faculty_dashboard_screen.dart';
import 'package:campus_erp/features/directory/presentation/faculty_directory_screen.dart';
import 'package:campus_erp/features/enrollment/presentation/staff_biometric_enrollment_screen.dart';
import 'package:campus_erp/core/services/auth_service.dart';
import 'package:campus_erp/core/services/leave_service.dart';
import 'package:campus_erp/core/services/staff_attendance_service.dart';
import 'package:campus_erp/core/widgets/user_profile_avatar_button.dart';
import 'package:campus_erp/features/leave/domain/models/leave_application.dart';
import 'package:campus_erp/features/leave/presentation/leave_management_screen.dart';
import 'package:campus_erp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smart Campus ERP Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusErpApp());
    expect(find.text('Smart Campus ERP'), findsWidgets);
    expect(find.text('Institutional Access'), findsOneWidget);

    // Verify Contact IT Admin and Forgot Password are removed
    expect(find.text('Contact IT Admin for Access'), findsNothing);
    expect(find.text('Forgot Password?'), findsNothing);

    // Verify Admin Login is present at the bottom right
    expect(find.text('Admin Login'), findsOneWidget);
  });

  testWidgets('Login as Admin routes directly to Admin Campus Attendance Management', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CampusErpApp());
    await tester.pumpAndSettle();

    // Tap Admin Login Tab
    await tester.tap(find.text('Admin Login'));
    await tester.pumpAndSettle();

    // Verify Admin fields are not autofilled
    expect(find.text('Sign In to Admin Portal'), findsOneWidget);
    expect(find.text('ADM-8910-HQ'), findsNothing);

    // Enter Admin demo credentials (ADMIN / admin123)
    await tester.enterText(find.byType(TextField).at(0), 'ADMIN');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.pumpAndSettle();

    // Tap Sign In to Admin Portal
    await tester.tap(find.text('Sign In to Admin Portal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify it navigated to Admin page, NOT staff/faculty page
    expect(find.text('Live Campus Attendance'), findsOneWidget);
    expect(find.text('CAMPUS ERP ADMIN'), findsOneWidget);
    expect(find.text("Today's Attendance Status"), findsNothing);
  });

  testWidgets('Login as Faculty routes directly to Faculty Dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CampusErpApp());
    await tester.pumpAndSettle();

    // Verify default is Faculty and fields are not autofilled
    expect(find.text('Sign In to Faculty Portal'), findsOneWidget);
    expect(find.text('FAC-2024-CS01'), findsNothing);

    // Enter Faculty demo credentials (faculty1 / demo123)
    await tester.enterText(find.byType(TextField).at(0), 'faculty1');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.pumpAndSettle();

    // Tap Sign In to Faculty Portal
    await tester.tap(find.text('Sign In to Faculty Portal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify it navigated to Faculty Dashboard
    expect(find.text("Today's Attendance Status"), findsOneWidget);
    expect(find.text('Live Campus Attendance'), findsNothing);
  });

  testWidgets('Faculty Dashboard renders in mobile mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FacultyDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text("Today's Attendance Status"), findsOneWidget);
  });

  testWidgets('Faculty Dashboard renders in desktop mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FacultyDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Smart Campus'), findsOneWidget);
    expect(find.text('ERP STAFF PORTAL'), findsOneWidget);
    expect(find.text('Faculty Attendance & Overview'), findsOneWidget);
  });

  testWidgets('Module 3: Mark Attendance renders correctly and opens biometric modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: MarkAttendanceScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and faculty details
    expect(find.text('Mark Faculty Attendance'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('Dept. of Computer Science & Engineering'), findsOneWidget);
    expect(find.text('DUTY INGRESS'), findsOneWidget);
    expect(find.text('Facial Biometrics Ready'), findsOneWidget);
    expect(find.text('Mark Check-Out Verification'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Check-Out button to trigger biometric modal
    await tester.tap(find.text('Mark Check-Out Verification'));
    await tester.pump();

    // Verify modal overlay is displayed
    expect(find.text('Face Identification'), findsOneWidget);

    // Let the 1500ms face scanning timer complete
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    // Close modal
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
  });

  testWidgets('Module 4: Facial Verification renders and triggers biometric capture', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool verifiedCallbackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: FacialVerificationScreen(
          onVerificationComplete: () {
            verifiedCallbackCalled = true;
          },
        ),
      ),
    );
    await tester.pump();

    // Verify screen title and badges
    expect(find.text('Facial Attendance Verification'), findsOneWidget);
    expect(find.text('Campus GPS & Wi-Fi Verified'), findsOneWidget);
    expect(find.text('Liveness On'), findsOneWidget);
    expect(find.text('Live Capture Protocol Active'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('SKIT-FAC-2024-8841'), findsOneWidget);
    expect(find.text('LT-04 Hall'), findsOneWidget);
    expect(find.text('Align eyes with the guide'), findsOneWidget);

    // Toggle Torch/fill light
    await tester.tap(find.byTooltip('Toggle Fill Light'));
    await tester.pump();
    expect(find.text('Fill light enabled'), findsOneWidget);

    // Toggle Camera Flip
    await tester.tap(find.byTooltip('Flip Camera Lens'));
    await tester.pump();
    expect(find.text('Rear Camera Active'), findsOneWidget);

    // Trigger Shutter Button
    await tester.tap(find.byIcon(Icons.face));
    await tester.pump();
    expect(find.text('Verifying Face Biometrics...'), findsOneWidget);

    // Let verification delay (900ms) resolve
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();

    expect(find.text('Verified • Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('Attendance Logged: 99.8% Match'), findsOneWidget);
    expect(verifiedCallbackCalled, isTrue);

    // Let toast timeout finish
    await tester.pump(const Duration(milliseconds: 3000));
  });

  testWidgets('Module 5: Attendance History renders calendar, filters, and export dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AttendanceHistoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and context
    expect(find.text('Attendance History'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('FACULTY ID #CS-4092'), findsOneWidget);
    expect(find.text('Monthly Overview'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify Attendance Map calendar matrix
    expect(find.text('ATTENDANCE MAP'), findsOneWidget);

    // Verify filter pills
    expect(find.text('All (22)'), findsOneWidget);
    expect(find.text('Leaves (2)'), findsOneWidget);

    // Filter to Leaves
    await tester.ensureVisible(find.text('Leaves (2)'));
    await tester.tap(find.text('Leaves (2)'));
    await tester.pumpAndSettle();

    // Verify only leaves entry is displayed
    expect(find.text('Duty Leave - Approved'), findsOneWidget);
    expect(find.text('Today, 24 Oct'), findsNothing);

    // Reset filter to All
    await tester.ensureVisible(find.text('All (22)'));
    await tester.tap(find.text('All (22)'));
    await tester.pumpAndSettle();
    expect(find.text('Today, 24 Oct'), findsOneWidget);

    // Test Export dialog
    await tester.ensureVisible(find.text('Export'));
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.text('Export Attendance'), findsOneWidget);
    expect(find.text('PDF Statement'), findsOneWidget);
    expect(find.text('Excel / CSV Ledger'), findsOneWidget);

    // Tap PDF export option
    await tester.tap(find.text('PDF Statement'));
    await tester.pump();

    // Verify snackbar confirmation
    expect(find.text('Exported Attendance Summary PDF'), findsOneWidget);
  });

  testWidgets('Module 6: Campus Attendance Management renders and filters staff roster', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CampusAttendanceManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and campus telemetry
    expect(find.text('Live Campus Attendance'), findsOneWidget);
    expect(find.text('CAMPUS ERP ADMIN'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);

    // Verify Bento cards with true staff count
    expect(find.text('Total Faculty'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
    expect(find.text('Present Today'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('All Staff (28)'), findsOneWidget);

    // Verify staff cards in roster
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('Dr. Ananya Pandey'), findsOneWidget);

    // Search query test
    await tester.enterText(find.byType(TextField).first, 'Ananya');
    await tester.pumpAndSettle();

    expect(find.text('Dr. Ananya Pandey'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);

    // Tap on a staff card to open record detail modal
    await tester.tap(find.text('Dr. Rajesh Sharma'));
    await tester.pumpAndSettle();

    // Verify modal appears
    expect(find.text('Assigned Venue'), findsOneWidget);
    expect(find.text('Turing Block'), findsWidgets);
    expect(find.text('SKIT-Campus-5G'), findsWidgets);
  });

  testWidgets('Module 7: Faculty & Staff Directory renders, filters, and displays profile', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FacultyDirectoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('CAMPUS ROSTER'), findsOneWidget);
    expect(find.text('Faculty & Staff Directory'), findsOneWidget);

    // Verify faculty items
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('Dr. Ananya Pandey'), findsOneWidget);
    expect(find.text('Prof. Vikram Malhotra'), findsOneWidget);

    // Filter by department chip
    await tester.ensureVisible(find.text('Computer Science'));
    await tester.tap(find.text('Computer Science'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('Dr. Ananya Pandey'), findsNothing);

    // Reset filter to All
    await tester.ensureVisible(find.text('All'));
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Ananya Pandey'), findsOneWidget);

    // Search query
    await tester.enterText(find.byType(TextField).first, 'Vikram');
    await tester.pumpAndSettle();

    expect(find.text('Prof. Vikram Malhotra'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma'), findsNothing);

    // Tap to open profile modal
    await tester.tap(find.text('Prof. Vikram Malhotra'));
    await tester.pumpAndSettle();

    // Verify modal content
    expect(find.text('Tesla Hall #208'), findsWidgets);
    expect(find.text('vikram.m@skit.ac.in'), findsOneWidget);
    expect(find.text('VLSI Design'), findsOneWidget);
    expect(find.text('Close Profile'), findsOneWidget);

    // Close modal
    await tester.tap(find.text('Close Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Close Profile'), findsNothing);
  });

  testWidgets('Module 8: Staff Biometric Enrollment renders, captures photo, and activates profile', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: StaffBiometricEnrollmentScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and engine telemetry
    expect(find.text('GATEWAY ENROLLMENT'), findsOneWidget);
    expect(find.text('Staff Biometric Enrollment'), findsOneWidget);
    expect(find.text('TURNSTILE EMBEDDING SUBSYSTEM'), findsOneWidget);
    expect(find.text('TensorRT v8.6'), findsOneWidget);

    // Verify fields
    expect(find.text('STAFF IDENTIFICATION'), findsOneWidget);
    expect(find.text('Staff Full Name'), findsOneWidget);
    expect(find.text('Employee ID / Staff Number'), findsOneWidget);

    // Test capture baseline photo with dual options (Take Photo & Choose Photo)
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose Photo'), findsOneWidget);

    // Verify choosing photo and cancelling does NOT make it green
    await tester.ensureVisible(find.text('Choose Photo'));
    await tester.tap(find.text('Choose Photo'));
    await tester.pumpAndSettle();
    expect(find.text('512-D Normalized Vector Verified'), findsNothing);

    // Now tap Take Photo to capture baseline
    await tester.ensureVisible(find.text('Take Photo'));
    await tester.tap(find.text('Take Photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify photo captured indicator and retake option
    expect(find.text('512-D Normalized Vector Verified'), findsOneWidget);
    expect(find.text('Retake Reference Photo'), findsOneWidget);

    // Dismiss active SnackBar before tapping submit
    ScaffoldMessenger.of(tester.element(find.byType(StaffBiometricEnrollmentScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // Submit enrollment to trigger success modal
    await tester.ensureVisible(find.text('Save & Activate Profile'));
    await tester.tap(find.text('Save & Activate Profile'));
    await tester.pumpAndSettle();

    // Verify modal content
    expect(find.text('Biometric Profile Activated'), findsOneWidget);
    expect(find.text('Edge nodes synced across 12 Turnstile Gateways.'), findsOneWidget);
    expect(find.text('Complete & Issue Campus Pass'), findsOneWidget);

    // Complete modal
    await tester.tap(find.text('Complete & Issue Campus Pass'));
    await tester.pumpAndSettle();
    expect(find.text('Biometric Profile Activated'), findsNothing);
  });

  testWidgets('Top right profile avatar opens session dialog and handles logout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool loggedOut = false;

    await tester.pumpWidget(
      MaterialApp(
        home: FacultyDashboardScreen(
          onLogoutPressed: () {
            loggedOut = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap profile avatar button at top right
    expect(find.byType(UserProfileAvatarButton), findsOneWidget);
    await tester.tap(find.byType(UserProfileAvatarButton));
    await tester.pumpAndSettle();

    // Verify profile session dialog is displayed
    expect(find.text('Active Account'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    // Tap Log Out
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    expect(loggedOut, isTrue);
  });

  testWidgets('Newly enrolled staff ID generates distinct, new attendance history and separate monthly overview stats', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Enroll/Login as a newly created staff member
    const newStaffId = 'FAC-2024-EC99';
    AuthService().setCurrentUser(
      AuthUser(
        id: 'user_ec99',
        name: 'Prof. Ananya Sen',
        email: 'ananya.sen@campus.edu',
        role: 'faculty',
        employeeId: newStaffId,
        department: 'Electronics & Communication',
        designation: 'Assistant Professor',
      ),
    );

    // Seed their initial onboarding history
    await StaffAttendanceService().seedInitialHistoryForStaff(
      employeeId: newStaffId,
      name: 'Prof. Ananya Sen',
      department: 'Electronics & Communication',
      designation: 'Assistant Professor',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AttendanceHistoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify newly generated staff profile header
    expect(find.text('Prof. Ananya Sen'), findsOneWidget);
    expect(find.text('FACULTY ID #FAC-2024-EC99'), findsOneWidget);

    // Verify dynamic overview stats are separate from default (e.g. 100.0% rate, 2 / 2 days, 0.0 leaves)
    expect(find.text('100.0%'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('0.0'), findsOneWidget);

    // Verify filter pills reflect newly generated records (All (2), Present (2), Leaves (0))
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Present (2)'), findsOneWidget);
    expect(find.text('Leaves (0)'), findsOneWidget);

    // Verify induction and onboarding log entry specific to EC department
    expect(find.text('Turnstile Gate A-12 • Electronics & Communication Block'), findsOneWidget);
    expect(find.text('Faculty induction, system briefing & department setup'), findsOneWidget);

    // Reset back to default faculty for clean test state
    AuthService().setCurrentUser(null);
  });

  testWidgets('LeaveManagementScreen renders faculty quotas, balance badges, and application history', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: LeaveManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Academic Session
    expect(find.text('Leave & Sanctions'), findsOneWidget);
    expect(find.text('AY 2024-25'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);

    // Verify Leave Quotas (CL, ML, OD, CO)
    expect(find.text('Casual Leave'), findsOneWidget);
    expect(find.text('Medical Leave'), findsOneWidget);
    expect(find.text('On-Duty Logged'), findsOneWidget);
    expect(find.text('Comp-Off Balance'), findsOneWidget);

    // Verify Action button
    expect(find.text('Apply for Leave / Duty Sanction'), findsOneWidget);

    // Verify Application History section and default cards
    expect(find.text('Application History'), findsOneWidget);
    expect(find.text('IEEE International Conference on AI in Higher Education (Keynote Speaker)'), findsOneWidget);
    expect(find.text('Personal family engagement & academic consultation'), findsOneWidget);
  });

  testWidgets('LeaveManagementScreen filter tabs correctly filter applications by status', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: LeaveManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Default 'All' shows both Approved and Pending applications
    expect(find.text('IEEE International Conference on AI in Higher Education (Keynote Speaker)'), findsOneWidget);
    expect(find.text('Personal family engagement & academic consultation'), findsOneWidget);

    // Tap 'Pending (1)' filter
    final pendingFilter = find.text('Pending (1)');
    expect(pendingFilter, findsOneWidget);
    await tester.tap(pendingFilter);
    await tester.pumpAndSettle();

    // Only pending item should be visible
    expect(find.text('State University Curriculum Revision Committee Member meeting'), findsOneWidget);
    expect(find.text('Personal family engagement & academic consultation'), findsNothing);

    // Tap 'Approved (2)' filter
    final approvedFilter = find.text('Approved (2)');
    expect(approvedFilter, findsOneWidget);
    await tester.tap(approvedFilter);
    await tester.pumpAndSettle();

    // Approved items should be visible
    expect(find.text('Personal family engagement & academic consultation'), findsOneWidget);
    expect(find.text('State University Curriculum Revision Committee Member meeting'), findsNothing);
  });

  testWidgets('Submitting a leave application updates the balance and ledger', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final leaveService = LeaveService();
    const staffId = 'FAC-2024-TEST1';
    final initialBalance = leaveService.getLeaveBalance(staffId);
    final initialCasualRemaining = initialBalance.casualLeaveRemaining;

    // Apply via service
    final newApp = LeaveApplication(
      id: 'LV-TEST-001',
      employeeId: staffId,
      applicantName: 'Test Faculty',
      department: 'Computer Science',
      leaveType: LeaveType.casual,
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      totalDays: 2.0,
      reason: 'Urgent personal work at hometown',
      status: LeaveStatus.pending,
      appliedAt: DateTime.now(),
    );

    await leaveService.submitLeaveApplication(newApp);

    final updatedBalance = leaveService.getLeaveBalance(staffId);
    expect(updatedBalance.casualLeaveRemaining, equals(initialCasualRemaining - 2.0));

    final apps = leaveService.getLeaveApplications(staffId);
    expect(apps.any((app) => app.reason == 'Urgent personal work at hometown'), isTrue);
  });

  testWidgets('Cancelling a pending leave application restores the quota balance', (WidgetTester tester) async {
    final leaveService = LeaveService();
    const staffId = 'FAC-2024-TEST2';
    final initialBalance = leaveService.getLeaveBalance(staffId);
    final initialMedical = initialBalance.medicalLeaveRemaining;

    // Apply for medical leave
    final medApp = LeaveApplication(
      id: 'LV-TEST-MED-01',
      employeeId: staffId,
      applicantName: 'Medical Test Faculty',
      department: 'Computer Science',
      leaveType: LeaveType.medical,
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 6)),
      totalDays: 2.0,
      reason: 'Scheduled health checkup',
      status: LeaveStatus.pending,
      appliedAt: DateTime.now(),
    );

    await leaveService.submitLeaveApplication(medApp);

    final apps = leaveService.getLeaveApplications(staffId);
    final pendingApp = apps.firstWhere((a) => a.reason == 'Scheduled health checkup');
    expect(pendingApp.status, equals(LeaveStatus.pending));

    // Medical balance should be reduced
    expect(leaveService.getLeaveBalance(staffId).medicalLeaveRemaining, equals(initialMedical - 2.0));

    // Now cancel the pending application
    await leaveService.cancelLeaveApplication(pendingApp.id, staffId);

    // Balance should be restored
    expect(leaveService.getLeaveBalance(staffId).medicalLeaveRemaining, equals(initialMedical));
  });

  testWidgets('Module 10 Leave & Sanctions is accessible in Main navigation hub and via bottom bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CampusErpApp());
    await tester.pumpAndSettle();

    // Login as Faculty with demo credentials
    await tester.enterText(find.byType(TextField).at(0), 'faculty1');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In to Faculty Portal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    // Wait for floating login snackbar to dismiss
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // We are on Faculty Dashboard. Tap bottom navigation 'Leave' tab
    final leaveNav = find.text('Leave');
    expect(leaveNav, findsOneWidget);
    await tester.tap(leaveNav);
    await tester.pumpAndSettle();

    // We should be on Leave & Sanctions screen
    expect(find.text('Leave & Sanctions'), findsOneWidget);
    expect(find.text('Apply for Leave / Duty Sanction'), findsOneWidget);

    // Tap back to Dashboard
    final dashboardNav = find.text('Dashboard');
    expect(dashboardNav, findsWidgets);
    await tester.tap(dashboardNav.first);
    await tester.pumpAndSettle();

    // Verified back on Dashboard
    expect(find.text("Today's Attendance Status"), findsOneWidget);
  });

  testWidgets('AdminLeaveApprovalScreen renders metrics bar, pending review items, and applicant quota cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLeaveApprovalScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leave & Sanction Clearance'), findsOneWidget);
    expect(find.textContaining('Applications for Review'), findsOneWidget);

    // Verify Metric Bento Cards
    expect(find.text('Pending Action'), findsOneWidget);
    expect(find.text('Approved'), findsWidgets);
    expect(find.text('Disapproved'), findsWidgets);

    // Verify pending demo applications are visible
    expect(find.text('Dr. Rajesh Sharma'), findsWidgets);
    expect(find.text('Prof. Vikram Malhotra'), findsWidgets);
  });

  testWidgets('Admin can approve a pending leave application with sanction remarks', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLeaveApprovalScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Find the first 'Approve Sanction' button
    final approveBtns = find.widgetWithText(ElevatedButton, 'Approve Sanction');
    expect(approveBtns, findsWidgets);

    await tester.tap(approveBtns.first);
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Approve Leave Sanction'), findsOneWidget);
    expect(find.text('Confirm Approval'), findsOneWidget);

    // Enter optional approval remarks
    await tester.enterText(find.byType(TextField).last, 'Approved by Dean Academic Affairs');
    await tester.pumpAndSettle();

    // Tap Confirm Approval
    await tester.tap(find.text('Confirm Approval'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify toast or snackbar
    expect(find.textContaining('approved successfully'), findsOneWidget);
  });

  testWidgets('Admin can disapprove a leave application with mandatory reason and quota is restored', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final leaveService = LeaveService();
    const staffId = 'SKIT-FAC-2024-7719';
    final initialBalance = leaveService.getLeaveBalance(staffId);
    final initialCLRemaining = initialBalance.casualLeaveRemaining;

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLeaveApprovalScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Find the Disapprove button
    final disapproveBtns = find.widgetWithText(OutlinedButton, 'Disapprove');
    expect(disapproveBtns, findsWidgets);

    await tester.tap(disapproveBtns.first);
    await tester.pumpAndSettle();

    // Verify Dialog opened
    expect(find.text('Disapprove Application'), findsOneWidget);
    expect(find.text('Disapprove & Restore Quota'), findsOneWidget);

    // Try tapping without reason - validation should fail
    await tester.tap(find.text('Disapprove & Restore Quota'));
    await tester.pumpAndSettle();
    expect(find.text('Please provide an administrative reason.'), findsOneWidget);

    // Now enter valid reason
    await tester.enterText(find.byType(TextField).last, 'Department mid-term exam invigilation duty');
    await tester.pumpAndSettle();

    // Tap Disapprove & Restore Quota
    await tester.tap(find.text('Disapprove & Restore Quota'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Quota should be restored
    expect(leaveService.getLeaveBalance(staffId).casualLeaveRemaining, greaterThanOrEqualTo(initialCLRemaining));
  });

  testWidgets('CampusAttendanceManagementScreen provides direct access to Admin Leave Approvals', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool leaveApprovalsOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CampusAttendanceManagementScreen(
          onLeaveApprovals: () {
            leaveApprovalsOpened = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check AppBar leave approval button with badge exists
    final approvalIcon = find.byIcon(Icons.approval_outlined);
    expect(approvalIcon, findsOneWidget);

    await tester.tap(approvalIcon);
    await tester.pumpAndSettle();

    expect(leaveApprovalsOpened, isTrue);
  });

  testWidgets('Admin can log out from CampusAttendanceManagementScreen via AppBar and confirmation dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool logoutCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CampusAttendanceManagementScreen(
          onLogoutPressed: () {
            logoutCalled = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap Admin Logout icon in AppBar
    final logoutIcon = find.byTooltip('Admin Logout');
    expect(logoutIcon, findsOneWidget);

    await tester.tap(logoutIcon);
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text('Admin Logout'), findsWidgets);
    expect(find.text('Log Out'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Cancel first
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(logoutCalled, isFalse);

    // Tap logout again and confirm
    await tester.tap(logoutIcon);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    expect(logoutCalled, isTrue);
  });

  testWidgets('Admin can log out from CampusAttendanceManagementScreen via Telemetry Header chip', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool logoutCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CampusAttendanceManagementScreen(
          onLogoutPressed: () {
            logoutCalled = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap Admin Logout chip in telemetry header
    final headerLogout = find.text('Admin Logout');
    expect(headerLogout, findsOneWidget);

    await tester.tap(headerLogout);
    await tester.pumpAndSettle();

    // Confirm dialog
    expect(find.text('Log Out'), findsOneWidget);
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    expect(logoutCalled, isTrue);
  });

  testWidgets('Admin can edit faculty details via 1-tap card edit button and see instant roster update', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CampusAttendanceManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial faculty member
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('Computer Science • Turing Block'), findsOneWidget);

    // Find and tap the edit button on the first card
    final editIcons = find.byTooltip('Edit Faculty Details');
    expect(editIcons, findsWidgets);

    await tester.tap(editIcons.first);
    await tester.pumpAndSettle();

    // Verify Edit Faculty Details dialog is displayed
    expect(find.text('Edit Faculty Details'), findsOneWidget);
    expect(find.text('Staff ID: SKIT-FAC-2024-8841'), findsOneWidget);

    // Modify name and department
    final nameField = find.widgetWithText(TextFormField, 'Dr. Rajesh Sharma');
    await tester.enterText(nameField, 'Dr. Rajesh Sharma (Director)');
    await tester.pumpAndSettle();

    final deptField = find.widgetWithText(TextFormField, 'Computer Science');
    await tester.enterText(deptField, 'AI & Data Science');
    await tester.pumpAndSettle();

    // Tap Save Details
    await tester.tap(find.text('Save Details'));
    await tester.pumpAndSettle();

    // Verify dialog closed and roster reflects edited details immediately
    expect(find.text('Dr. Rajesh Sharma (Director)'), findsOneWidget);
    expect(find.text('AI & Data Science • Turing Block'), findsOneWidget);
  });

  testWidgets('Admin can edit faculty details from staff detail bottom sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CampusAttendanceManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap card for Dr. Ananya Pandey to open detail bottom sheet
    await tester.tap(find.text('Dr. Ananya Pandey'));
    await tester.pumpAndSettle();

    // Verify bottom sheet has Edit Details button
    expect(find.text('Edit Details'), findsOneWidget);
    expect(find.text('Send Notice'), findsOneWidget);

    // Tap Edit Details
    await tester.tap(find.text('Edit Details'));
    await tester.pumpAndSettle();

    // Verify dialog opened for Dr. Ananya Pandey
    expect(find.text('Edit Faculty Details'), findsOneWidget);
    expect(find.text('Staff ID: SKIT-FAC-2024-9102'), findsOneWidget);

    // Change Department
    final deptField = find.widgetWithText(TextFormField, 'Mechanical Engg');
    await tester.enterText(deptField, 'Robotics & Automation');
    await tester.pumpAndSettle();

    // Tap Save Details
    await tester.tap(find.text('Save Details'));
    await tester.pumpAndSettle();

    // Verify updated department on roster
    expect(find.text('Robotics & Automation • LT-04 Hall'), findsOneWidget);
  });

  testWidgets('Admin can edit and update faculty image via Take Photo in Edit Faculty Details dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CampusAttendanceManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Edit Faculty Details for Dr. Rajesh Sharma
    final editIcons = find.byTooltip('Edit Faculty Details');
    expect(editIcons, findsWidgets);
    await tester.tap(editIcons.first);
    await tester.pumpAndSettle();

    // Verify dialog has photo editing options
    expect(find.text('Edit Faculty Details'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose Photo'), findsOneWidget);
    expect(find.text('No Profile Photo Assigned'), findsOneWidget);

    // Tap Take Photo
    await tester.tap(find.text('Take Photo'));
    await tester.pumpAndSettle();

    // Verify photo attached
    expect(find.text('Faculty Photo Attached'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);

    // Tap Save Details
    await tester.tap(find.text('Save Details'));
    await tester.pumpAndSettle();

    // Re-open dialog to verify persisted in localEdits
    await tester.tap(find.byTooltip('Edit Faculty Details').first);
    await tester.pumpAndSettle();

    expect(find.text('Faculty Photo Attached'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);

    // Test removing photo
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('No Profile Photo Assigned'), findsOneWidget);

    // Save with removed photo
    await tester.tap(find.text('Save Details'));
    await tester.pumpAndSettle();
  });

  testWidgets('Staff Biometric Enrollment: cancelling photo selection does not turn section green and Clear button works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(450, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: StaffBiometricEnrollmentScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial un-enrolled state
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose Photo'), findsOneWidget);
    expect(find.text('ISO/IEC 19794-5'), findsOneWidget);
    expect(find.text('512-D Normalized Vector Verified'), findsNothing);

    // Tap Choose Photo (simulates cancelling)
    await tester.ensureVisible(find.text('Choose Photo'));
    await tester.tap(find.text('Choose Photo'));
    await tester.pumpAndSettle();

    // Must still NOT be green / verified
    expect(find.text('512-D Normalized Vector Verified'), findsNothing);
    expect(find.text('ISO 19794-5 VERIFIED'), findsNothing);

    // Now tap Take Photo
    await tester.ensureVisible(find.text('Take Photo'));
    await tester.tap(find.text('Take Photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify verified state with ISO badge and retake options
    expect(find.text('ISO 19794-5 VERIFIED'), findsOneWidget);
    expect(find.text('512-D Normalized Vector Verified'), findsOneWidget);
    expect(find.text('Retake Reference Photo'), findsOneWidget);
    expect(find.text('Choose Another Photo'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);

    // Tap Clear
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // Verify reset to initial un-enrolled state
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose Photo'), findsOneWidget);
    expect(find.text('512-D Normalized Vector Verified'), findsNothing);
  });

  testWidgets('Login screen starts with empty fields and switching tabs keeps fields empty', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CampusErpApp());
    await tester.pumpAndSettle();

    // Check Faculty ID & Password are both empty
    final facultyIdFinder = find.byType(TextField).at(0);
    final facultyPassFinder = find.byType(TextField).at(1);
    expect((tester.widget(facultyIdFinder) as TextField).controller?.text, isEmpty);
    expect((tester.widget(facultyPassFinder) as TextField).controller?.text, isEmpty);
    expect(find.text('FAC-2024-CS01'), findsNothing);
    expect(find.text('faculty123'), findsNothing);

    // Switch to Admin
    await tester.tap(find.text('Admin Login'));
    await tester.pumpAndSettle();

    final adminIdFinder = find.byType(TextField).at(0);
    final adminPassFinder = find.byType(TextField).at(1);
    expect((tester.widget(adminIdFinder) as TextField).controller?.text, isEmpty);
    expect((tester.widget(adminPassFinder) as TextField).controller?.text, isEmpty);
    expect(find.text('ADM-8910-HQ'), findsNothing);
    expect(find.text('admin123'), findsNothing);

    // Type something in Admin then switch back to Faculty - should clear
    await tester.enterText(adminIdFinder, 'ADMIN');
    await tester.enterText(adminPassFinder, 'randompass');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Faculty Login'));
    await tester.pumpAndSettle();

    expect((tester.widget(find.byType(TextField).at(0)) as TextField).controller?.text, isEmpty);
    expect((tester.widget(find.byType(TextField).at(1)) as TextField).controller?.text, isEmpty);
  });

  testWidgets('Login with invalid credentials displays error snackbar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CampusErpApp());
    await tester.pumpAndSettle();

    // Enter valid demo faculty username with wrong password
    await tester.enterText(find.byType(TextField).at(0), 'faculty1');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In to Faculty Portal'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Invalid password. Please verify your credentials and try again.'), findsOneWidget);
  });
}



