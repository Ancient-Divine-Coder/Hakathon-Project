import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/staff_attendance_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/campus_notification_bell_button.dart';
import '../../../core/widgets/faculty_bottom_navigation_bar.dart';
import '../../../core/widgets/user_profile_avatar_button.dart';
import '../domain/models/monthly_overview_stats.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  final VoidCallback? onDashboardPressed;
  final VoidCallback? onAttendancePressed;
  final VoidCallback? onLeavePressed;
  final VoidCallback? onLogoutPressed;

  const AttendanceHistoryScreen({
    super.key,
    this.onBackToDashboard,
    this.onDashboardPressed,
    this.onAttendancePressed,
    this.onLeavePressed,
    this.onLogoutPressed,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final List<String> _months = [
    'August 2024',
    'September 2024',
    'October 2024',
    'November 2024',
  ];
  final int _currentMonthIndex = 2; // October 2024

  String _selectedFilter = 'all'; // 'all', 'present', 'irregular', 'leaves'
  int _selectedDay = 24;


  AttendanceLogEntry _mapDocToEntry(Map<String, dynamic> data, String docId) {
    final statusLabel = data['statusLabel']?.toString() ?? 'Present';
    String category = data['category']?.toString() ?? 'present';
    IconData icon = Icons.check;
    final lowerStatus = statusLabel.toLowerCase();
    if (data['category'] == null) {
      if (lowerStatus.contains('late') || lowerStatus.contains('irregular')) {
        category = 'irregular';
      } else if (lowerStatus.contains('duty') || lowerStatus.contains('leave')) {
        category = 'leaves';
      }
    }

    if (category == 'irregular') {
      icon = Icons.info_outline;
    } else if (category == 'leaves') {
      icon = Icons.task_alt;
    } else if (lowerStatus.contains('biometric')) {
      icon = Icons.fingerprint;
    }

    final inTime = data['inTime']?.toString() ?? '08:30 AM';
    final outTime = data['outTime']?.toString() ?? '--:--';
    final isLive = outTime == '--:--' || outTime == 'In Progress';

    return AttendanceLogEntry(
      dateTitle: data['dateTitle']?.toString() ?? docId,
      location: data['gateTurnstile']?.toString() ??
          data['sessionSubtitle']?.toString() ??
          'Turnstile Gate 2',
      category: category,
      badgeText: statusLabel,
      badgeIcon: icon,
      checkIn: inTime,
      checkOut: outTime,
      duration: data['totalHours']?.toString() ?? '8h',
      subnote: data['sessionSubtitle']?.toString(),
      isLive: isLive,
      isLeave: category == 'leaves',
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Export Attendance',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate an institutional audit statement for ${_months[_currentMonthIndex]}:',
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.error,
                ),
                title: Text(
                  'PDF Statement',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Institutional stamp & barcode included',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showToast('Exported Attendance Summary PDF');
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.table_chart_outlined,
                  color: AppColors.success,
                ),
                title: Text(
                  'Excel / CSV Ledger',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Raw ingress/egress biometric timestamps',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showToast('Exported Attendance Ledger (CSV)');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.surfaceBright,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMd.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.2),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.2,
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.school, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SMART CAMPUS',
                    style: AppTypography.labelSm.copyWith(
                      letterSpacing: 0.8,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Attendance History',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const CampusNotificationBellButton(size: 22),
          UserProfileAvatarButton(
            onLogout: widget.onLogoutPressed,
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firebase.apps.isNotEmpty
            ? FirebaseFirestore.instance
                .collection('attendance_history')
                .snapshots()
            : null,
        builder: (context, snapshot) {
          final user = AuthService().currentUser;
          final isDefaultFaculty = user == null ||
              user.employeeId.isEmpty ||
              user.employeeId == 'FAC-2024-CS01' ||
              user.employeeId == 'CS-4092';
          final empId = (user != null && user.employeeId.isNotEmpty)
              ? user.employeeId
              : 'FAC-2024-CS01';

          List<AttendanceLogEntry> firestoreEntries = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final userDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final docEmpId = data['employeeId']?.toString() ?? '';
              if (isDefaultFaculty) {
                return docEmpId.toUpperCase() == 'FAC-2024-CS01' ||
                    docEmpId.toUpperCase() == 'CS-4092';
              }
              return docEmpId.toUpperCase() == empId.toUpperCase();
            }).toList();

            if (userDocs.isNotEmpty) {
              firestoreEntries = userDocs.map((doc) {
                return _mapDocToEntry(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              }).toList();
            }
          }

          final entries = StaffAttendanceService().getLogsForStaff(
            employeeId: empId,
            firestoreEntries:
                firestoreEntries.isNotEmpty ? firestoreEntries : null,
            staffName: user?.name,
            department: user?.department,
          );

          final stats = StaffAttendanceService().calculateOverviewStats(
            entries,
            isDefault: isDefaultFaculty && firestoreEntries.isEmpty,
          );

          final totalCount = entries.length;
          final presentCount =
              entries.where((e) => e.category == 'present').length;
          final irregularCount =
              entries.where((e) => e.category == 'irregular').length;
          final leavesCount =
              entries.where((e) => e.category == 'leaves').length;

          final filtered = _selectedFilter == 'all'
              ? entries
              : entries.where((e) => e.category == _selectedFilter).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Faculty Profile Quick Banner & Export Action
                    _buildFacultyBanner(),
                    const SizedBox(height: 16),

                    // 1. Monthly Overview Metrics
                    _buildMonthlyOverviewCard(stats),
                    const SizedBox(height: 16),

                    // 2. Attendance Map / Calendar Grid
                    _buildAttendanceMapCard(
                      entries,
                      isDefault: isDefaultFaculty && firestoreEntries.isEmpty,
                    ),
                    const SizedBox(height: 16),

                    // Filter Pills Bar
                    _buildFilterPillsBar(
                      totalCount: totalCount,
                      presentCount: presentCount,
                      irregularCount: irregularCount,
                      leavesCount: leavesCount,
                    ),
                    const SizedBox(height: 16),

                    // 3. Chronological Daily Log Entries from Firestore
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'No attendance records found for this filter.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: filtered.map(_buildLogCard).toList(),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: FacultyBottomNavigationBar(
        currentIndex: 2,
        onDashboardPressed:
            widget.onDashboardPressed ?? widget.onBackToDashboard,
        onAttendancePressed: widget.onAttendancePressed,
        onLeavePressed: widget.onLeavePressed,
      ),
    );
  }

  // ==========================================
  // FACULTY BANNER & EXPORT ACTION
  // ==========================================
  Widget _buildFacultyBanner() {
    final user = AuthService().currentUser;
    final facultyName = user?.name.isNotEmpty == true ? user!.name : 'Dr. Rajesh Sharma';
    final empId = (user != null &&
            user.employeeId.isNotEmpty &&
            user.employeeId != 'FAC-2024-CS01')
        ? user.employeeId
        : 'CS-4092';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEEF2FF),
                    border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
                  ),
                  child: (user?.photoBase64 != null && user!.photoBase64!.isNotEmpty)
                      ? ClipOval(
                          child: Image.memory(
                            base64Decode(user.photoBase64!),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.badge_outlined,
                              size: 22,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.badge_outlined,
                          size: 22,
                          color: Color(0xFF4F46E5),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACULTY ID #$empId',
                        style: AppTypography.codeSm.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4F46E5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        facultyName,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _showExportDialog,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.download, size: 18, color: Color(0xFF4F46E5)),
            label: Text(
              'Export',
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. MONTHLY OVERVIEW METRICS
  // ==========================================
  Widget _buildMonthlyOverviewCard(MonthlyOverviewStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_outlined,
                      color: Color(0xFF4F46E5),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Monthly Overview',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
                ),
                child: Text(
                  stats.monthLabel,
                  style: AppTypography.codeSm.copyWith(
                    color: const Color(0xFF4338CA),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Metric Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              _buildMetricTile(
                title: 'ATTENDANCE RATE',
                value: stats.attendanceRate,
                caption: stats.attendanceRateCaption,
                captionColor: const Color(0xFF059669),
              ),
              _buildMetricTile(
                title: 'DAYS PRESENT',
                value: '${stats.daysPresent} / ${stats.totalWorkingDays}',
                caption: 'Active shifts',
                captionColor: const Color(0xFF64748B),
              ),
              _buildMetricTile(
                title: 'LEAVES TAKEN',
                value: stats.leavesTaken.toStringAsFixed(1),
                caption: stats.leavesTaken > 0
                    ? 'Sanctioned leaves'
                    : 'No leaves taken',
                captionColor: const Color(0xFF64748B),
              ),
              _buildMetricTile(
                title: 'ON-TIME SCORE',
                value: stats.onTimeScore,
                caption: 'Consistent',
                captionColor: const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'All records verified',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stats.cycleEndsLabel,
                style: AppTypography.codeSm.copyWith(
                  color: const Color(0xFF4F46E5),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String caption,
    required Color captionColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              color: captionColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. ATTENDANCE MAP (MINI CALENDAR MATRIX)
  // ==========================================
  Widget _buildAttendanceMapCard(List<AttendanceLogEntry> entries,
      {bool isDefault = false}) {
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final presentDays = <int>{};
    final leaveDays = <int>{};

    if (isDefault) {
      for (int d = 1; d <= 24; d++) {
        final isWeekend =
            (d == 5 || d == 6 || d == 12 || d == 13 || d == 19 || d == 20);
        if (!isWeekend && d != 18 && d != 10) {
          presentDays.add(d);
        }
      }
      leaveDays.add(18);
      leaveDays.add(10);
    } else {
      final dayRegex = RegExp(r'\b(\d{1,2})\b');
      for (final entry in entries) {
        final match = dayRegex.firstMatch(entry.dateTitle);
        if (match != null) {
          final dayNum = int.tryParse(match.group(1)!);
          if (dayNum != null && dayNum >= 1 && dayNum <= 31) {
            if (entry.category == 'leaves') {
              leaveDays.add(dayNum);
            } else {
              presentDays.add(dayNum);
            }
          }
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'ATTENDANCE MAP',
                  style: AppTypography.labelSm.copyWith(
                    color: const Color(0xFF475569),
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Present',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Leave',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day Names Row
          Row(
            children: daysOfWeek.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Calendar Grid (October 2024 sample layout)
          // 30 Sept (prev), 1..31 Oct
          _buildCalendarRow([30], [1, 2, 3, 4, 5, 6], presentDays, leaveDays,
              isFirstRow: true),
          _buildCalendarRow(
              [], [7, 8, 9, 10, 11, 12, 13], presentDays, leaveDays),
          _buildCalendarRow(
              [], [14, 15, 16, 17, 18, 19, 20], presentDays, leaveDays),
          _buildCalendarRow(
              [], [21, 22, 23, 24, 25, 26, 27], presentDays, leaveDays),
        ],
      ),
    );
  }

  Widget _buildCalendarRow(
    List<int> prevDays,
    List<int> currentDays,
    Set<int> presentDays,
    Set<int> leaveDays, {
    bool isFirstRow = false,
  }) {
    final allDays = [...prevDays, ...currentDays];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: allDays.map((day) {
          final isPrevMonth = prevDays.contains(day);
          final isToday = day == 24 && !isPrevMonth;
          final isLeave = leaveDays.contains(day) && !isPrevMonth;
          final isWeekend = (day == 5 ||
              day == 6 ||
              day == 12 ||
              day == 13 ||
              day == 19 ||
              day == 20 ||
              day == 26 ||
              day == 27);
          final isPresent = presentDays.contains(day) && !isPrevMonth;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isPrevMonth) {
                  setState(() => _selectedDay = day);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF4F46E5)
                      : (_selectedDay == day && !isPrevMonth
                          ? const Color(0xFFEEF2FF)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$day',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12,
                        fontWeight: (isToday || day == _selectedDay)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? Colors.white
                            : (isPrevMonth || isWeekend
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF1E293B)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? Colors.white
                            : (isPresent
                                ? const Color(0xFF4F46E5)
                                : (isLeave
                                    ? const Color(0xFFF59E0B)
                                    : Colors.transparent)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // FILTER PILLS BAR
  // ==========================================
  Widget _buildFilterPillsBar({
    required int totalCount,
    required int presentCount,
    required int irregularCount,
    required int leavesCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'All ($totalCount)'),
          const SizedBox(width: 8),
          _buildFilterChip('present', 'Present ($presentCount)'),
          const SizedBox(width: 8),
          _buildFilterChip('irregular', 'Irregular/Late ($irregularCount)'),
          const SizedBox(width: 8),
          _buildFilterChip('leaves', 'Leaves ($leavesCount)'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. DAILY LOG CARD
  // ==========================================
  Widget _buildLogCard(AttendanceLogEntry entry) {
    Color badgeBg;
    Color badgeFg;
    if (entry.isLive) {
      badgeBg = const Color(0xFFECFDF5);
      badgeFg = const Color(0xFF047857);
    } else if (entry.isLeave) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeFg = const Color(0xFFB45309);
    } else if (entry.category == 'irregular') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeFg = const Color(0xFFDC2626);
    } else {
      badgeBg = const Color(0xFFEEF2FF);
      badgeFg = const Color(0xFF4338CA);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Date & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: entry.isLeave
                            ? const Color(0xFFFEF3C7)
                            : (entry.category == 'irregular'
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFEEF2FF)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        entry.badgeIcon,
                        size: 20,
                        color: entry.isLeave
                            ? const Color(0xFFD97706)
                            : (entry.category == 'irregular'
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF4F46E5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.dateTitle,
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            entry.location,
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: badgeFg.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entry.isLive) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Flexible(
                        child: Text(
                          entry.badgeText,
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                            color: badgeFg,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metrics Block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.isLeave ? 'Type' : 'Check-in',
                              style: AppTypography.labelSm.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              entry.checkIn,
                              style: AppTypography.codeSm.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '→',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.isLeave ? 'Credits' : 'Check-out',
                              style: AppTypography.labelSm.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              entry.checkOut,
                              style: AppTypography.codeSm.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: entry.isLive
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      entry.isLeave ? 'Status' : 'Duration',
                      style: AppTypography.labelSm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      entry.duration,
                      style: AppTypography.codeSm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subnote (Grace / Remarks)
          if (entry.subnote != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.subnote!,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AttendanceLogEntry {
  final String dateTitle;
  final String location;
  final String category;
  final String badgeText;
  final IconData badgeIcon;
  final String checkIn;
  final String checkOut;
  final String duration;
  final String? subnote;
  final bool isLive;
  final bool isLeave;

  AttendanceLogEntry({
    required this.dateTitle,
    required this.location,
    required this.category,
    required this.badgeText,
    required this.badgeIcon,
    required this.checkIn,
    required this.checkOut,
    required this.duration,
    this.subnote,
    this.isLive = false,
    this.isLeave = false,
  });
}
