import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'features/admin/presentation/admin_broadcast_screen.dart';
import 'features/admin/presentation/admin_leave_approval_screen.dart';
import 'features/admin/presentation/campus_attendance_management_screen.dart';
import 'features/attendance/presentation/attendance_history_screen.dart';
import 'features/attendance/presentation/facial_verification_screen.dart';
import 'features/attendance/presentation/mark_attendance_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/faculty_dashboard_screen.dart';
import 'features/directory/presentation/faculty_directory_screen.dart';
import 'features/enrollment/presentation/staff_biometric_enrollment_screen.dart';
import 'features/firestore_test/presentation/firestore_test_screen.dart';
import 'features/leave/presentation/leave_management_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Synchronize initial demo credentials (faculty1 / demo123 and ADMIN / admin123)
  seedCampusDatabase();

  runApp(const CampusErpApp());
}

class CampusErpApp extends StatelessWidget {
  const CampusErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainModuleNavigationWrapper(),
    );
  }
}

class MainModuleNavigationWrapper extends StatefulWidget {
  const MainModuleNavigationWrapper({super.key});

  @override
  State<MainModuleNavigationWrapper> createState() =>
      _MainModuleNavigationWrapperState();
}

class _MainModuleNavigationWrapperState
    extends State<MainModuleNavigationWrapper> {
  int _currentModuleIndex = 0;

  late final List<ModuleItem> _modules;

  @override
  void initState() {
    super.initState();
    _modules = [
      ModuleItem(
        title: 'Module 1: Portal Login',
        subtitle: 'Role-based authentication gateway (Faculty & Admin)',
        icon: Icons.shield_outlined,
        widget: LoginScreen(
          onLoginSuccess: (role) {
            if (role == PortalRole.admin) {
              selectModule(5); // Admin: Campus Attendance Management
            } else {
              selectModule(1); // Faculty: Faculty Dashboard
            }
          },
        ),
      ),
      ModuleItem(
        title: 'Module 2: Faculty Dashboard',
        subtitle: 'Duty cycle, shift progress, geofence, and monthly metrics',
        icon: Icons.dashboard_outlined,
        widget: FacultyDashboardScreen(
          onLogoutPressed: () {
            selectModule(0);
          },
          onMarkAttendancePressed: () {
            selectModule(2);
          },
          onHistoryPressed: () {
            selectModule(4);
          },
          onLeavePressed: () {
            selectModule(9);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 3: Mark Attendance',
        subtitle: 'Duty cycle ticker, biometrics & campus telemetry',
        icon: Icons.fingerprint_outlined,
        widget: MarkAttendanceScreen(
          onBackToDashboard: () {
            selectModule(1);
          },
          onDashboardPressed: () {
            selectModule(1);
          },
          onHistoryPressed: () {
            selectModule(4);
          },
          onLeavePressed: () {
            selectModule(9);
          },
          onOpenFacialVerification: () {
            selectModule(3);
          },
          onLogoutPressed: () {
            selectModule(0);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 4: Facial Verification',
        subtitle: 'Live viewfinder HUD, liveness detection & biometric match',
        icon: Icons.face_retouching_natural,
        widget: FacialVerificationScreen(
          onBack: () {
            selectModule(2);
          },
          onVerificationComplete: () {
            // Provide a graceful celebration window so user views the success card & metrics
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (mounted) selectModule(1);
            });
          },
        ),
      ),
      ModuleItem(
        title: 'Module 5: Attendance History',
        subtitle: 'Calendar matrix, monthly compliance stats & duty logs',
        icon: Icons.calendar_month_outlined,
        widget: AttendanceHistoryScreen(
          onBackToDashboard: () {
            selectModule(1);
          },
          onDashboardPressed: () {
            selectModule(1);
          },
          onAttendancePressed: () {
            selectModule(2);
          },
          onLeavePressed: () {
            selectModule(9);
          },
          onLogoutPressed: () {
            selectModule(0);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 6: Campus Attendance Management',
        subtitle: 'Admin real-time staff roster, geofence audit & anomaly flags',
        icon: Icons.admin_panel_settings_outlined,
        widget: CampusAttendanceManagementScreen(
          onBack: () {
            selectModule(0);
          },
          onLogoutPressed: () {
            selectModule(0);
          },
          onEnrollStaff: () {
            selectModule(7);
          },
          onLeaveApprovals: () {
            selectModule(10);
          },
          onBroadcast: () {
            selectModule(11);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 7: Faculty & Staff Directory',
        subtitle: 'Search faculty, department roster, office cabins & contact',
        icon: Icons.people_alt_outlined,
        widget: FacultyDirectoryScreen(
          onBack: () {
            selectModule(1);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 8: Staff Biometric Enrollment',
        subtitle: 'Baseline facial vector & turnstile provisioning',
        icon: Icons.how_to_reg_outlined,
        widget: StaffBiometricEnrollmentScreen(
          onBack: () {
            selectModule(5);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 9: Firestore Service & Live Test',
        subtitle: 'Read & write testing, latency diagnostics, and real-time streams',
        icon: Icons.cloud_sync_outlined,
        widget: FirestoreTestScreen(
          onBack: () {
            selectModule(1);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 10: Leave & Sanctions',
        subtitle: 'Casual, medical & OD quotas, application status & approval ledger',
        icon: Icons.time_to_leave_outlined,
        widget: LeaveManagementScreen(
          onBackToDashboard: () {
            selectModule(1);
          },
          onDashboardPressed: () {
            selectModule(1);
          },
          onAttendancePressed: () {
            selectModule(2);
          },
          onHistoryPressed: () {
            selectModule(4);
          },
          onLogoutPressed: () {
            selectModule(0);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 11: Admin Leave Approvals',
        subtitle: 'Review & sanction faculty leave applications, inspect quotas & remarks',
        icon: Icons.approval_outlined,
        widget: AdminLeaveApprovalScreen(
          onBack: () {
            selectModule(5);
          },
        ),
      ),
      ModuleItem(
        title: 'Module 12: Admin Campus Broadcast & Notices',
        subtitle: 'Dispatch institutional circulars, department advisories & urgent alerts',
        icon: Icons.campaign_outlined,
        widget: AdminBroadcastScreen(
          onBack: () {
            selectModule(5);
          },
          onLogoutPressed: () {
            selectModule(0);
          },
        ),
      ),
    ];
  }

  void selectModule(int index) {
    if (index >= 0 && index < _modules.length) {
      setState(() {
        _currentModuleIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _modules[_currentModuleIndex];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.surfaceContainerLowest,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus ERP',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Module Navigation Hub',
                          style: AppTypography.labelSm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _modules.length,
                  itemBuilder: (context, index) {
                    final module = _modules[index];
                    final isSelected = index == _currentModuleIndex;

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppColors.surfaceContainerLow,
                      leading: Icon(
                        module.icon,
                        color: isSelected
                            ? AppColors.primaryContainer
                            : AppColors.secondary,
                      ),
                      title: Text(
                        module.title,
                        style: AppTypography.labelMd.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryContainer
                              : AppColors.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        module.subtitle,
                        style: AppTypography.bodySm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        selectModule(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Building modules one-by-one with Stitch specs',
                  textAlign: TextAlign.center,
                  style: AppTypography.codeSm.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
      body: current.widget,
    );
  }
}

class ModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget widget;

  const ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.widget,
  });
}

/// Seeds initial admin, faculty, and attendance logs into Firestore.
Future<void> seedCampusDatabase() async {
  try {
    final db = FirebaseFirestore.instance;

    // 1. Create Users (1 Admin + 2 Faculty)
    await db.collection('users').doc('admin_hq').set({
      'email': 'admin@campus.edu',
      'username': 'ADMIN',
      'password': 'admin123',
      'name': 'Campus System Administrator',
      'role': 'admin',
      'employeeId': 'ADMIN',
      'department': 'Administration',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.collection('users').doc('ADMIN').set({
      'email': 'admin@campus.edu',
      'username': 'ADMIN',
      'password': 'admin123',
      'name': 'Campus System Administrator',
      'role': 'admin',
      'employeeId': 'ADMIN',
      'department': 'Administration',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.collection('users').doc('faculty_cs01').set({
      'email': 'rajesh.sharma@campus.edu',
      'username': 'faculty1',
      'password': 'demo123',
      'name': 'Dr. Rajesh Sharma',
      'role': 'faculty',
      'employeeId': 'FAC-2024-CS01',
      'department': 'Computer Science',
      'designation': 'Professor & HOD',
      'cabinNumber': 'TW-402',
      'block': 'Turing Wing, 4th Floor',
      'scheduledShift': '08:30 – 16:30 IST',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.collection('users').doc('faculty1').set({
      'email': 'rajesh.sharma@campus.edu',
      'username': 'faculty1',
      'password': 'demo123',
      'name': 'Dr. Rajesh Sharma',
      'role': 'faculty',
      'employeeId': 'FAC-2024-CS01',
      'department': 'Computer Science',
      'designation': 'Professor & HOD',
      'cabinNumber': 'TW-402',
      'block': 'Turing Wing, 4th Floor',
      'scheduledShift': '08:30 – 16:30 IST',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.collection('users').doc('faculty_ec04').set({
      'email': 'priya.nair@campus.edu',
      'password': 'demo123',
      'name': 'Prof. Priya Nair',
      'role': 'faculty',
      'employeeId': 'FAC-2024-EC04',
      'department': 'Electronics & Comm',
      'designation': 'Associate Professor',
      'cabinNumber': 'EC-204',
      'block': 'Ramanujan Hall, 2nd Floor',
      'scheduledShift': '09:00 – 17:00 IST',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Create Attendance History Logs
    await db.collection('attendance_history').doc('log_2026_10_14').set({
      'employeeId': 'FAC-2024-CS01',
      'dateTitle': 'Today - Oct 14, 2026',
      'sessionSubtitle': 'Regular Duty Shift • CSE Dept',
      'inTime': '08:24 AM',
      'outTime': '--:--',
      'totalHours': '3h 48m (In Progress)',
      'statusLabel': 'Present',
      'gateTurnstile': 'Turnstile Gate 2 (Biometric)',
      'isRegular': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.collection('attendance_history').doc('log_2026_10_13').set({
      'employeeId': 'FAC-2024-CS01',
      'dateTitle': 'Yesterday - Oct 13, 2026',
      'sessionSubtitle': 'Regular Duty Shift • CSE Dept',
      'inTime': '08:28 AM',
      'outTime': '04:36 PM',
      'totalHours': '8h 08m',
      'statusLabel': 'Present',
      'gateTurnstile': 'Turnstile Gate 1 (Facial)',
      'isRegular': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.collection('attendance_history').doc('log_2026_10_10').set({
      'employeeId': 'FAC-2024-CS01',
      'dateTitle': 'Fri - Oct 10, 2026',
      'sessionSubtitle': 'Traffic Delay Regularized',
      'inTime': '09:12 AM',
      'outTime': '05:15 PM',
      'totalHours': '8h 03m',
      'statusLabel': 'Late',
      'gateTurnstile': 'Admin Security Gate',
      'isRegular': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('Database seeded successfully with initial users and attendance logs!');
  } catch (e) {
    debugPrint('Error seeding database: $e');
  }
}
