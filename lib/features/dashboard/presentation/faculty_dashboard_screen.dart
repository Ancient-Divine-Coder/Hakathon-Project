import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/staff_attendance_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/campus_notification_bell_button.dart';
import '../../../core/widgets/faculty_bottom_navigation_bar.dart';
import '../../../core/widgets/user_profile_avatar_button.dart';
import '../../attendance/presentation/attendance_history_screen.dart';

class FacultyDashboardScreen extends StatefulWidget {
  final VoidCallback? onMarkAttendancePressed;
  final VoidCallback? onHistoryPressed;
  final VoidCallback? onLeavePressed;
  final VoidCallback? onLogoutPressed;

  const FacultyDashboardScreen({
    super.key,
    this.onMarkAttendancePressed,
    this.onHistoryPressed,
    this.onLeavePressed,
    this.onLogoutPressed,
  });

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  bool _isNoticeDismissed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        if (isDesktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // ==========================================
  // DESKTOP / WEB LAYOUT (12-col responsive)
  // ==========================================
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Left Sidebar (Navigation Rail)
          _buildDesktopSidebar(),

          // Main Viewport Area
          Expanded(
            child: Column(
              children: [
                _buildDesktopTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Page title & live active session header
                            _buildDesktopPageHeader(),
                            const SizedBox(height: 18),

                            // Geofence & Wi-Fi Policy Notice
                            if (!_isNoticeDismissed) ...[
                              _buildNoticeBanner(),
                              const SizedBox(height: 16),
                            ],

                            // Faculty Profile Summary Card
                            _buildProfileSummaryCard(isDesktop: true),
                            const SizedBox(height: 18),

                            // Today's Attendance Status
                            _buildTodayAttendanceCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
      ),
      child: Column(
        children: [
          // Logo & Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF818CF8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Smart Campus',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'ERP STAFF PORTAL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSm.copyWith(
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),

          // Nav links
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 18, bottom: 8, right: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'FACULTY OPS',
                style: AppTypography.labelSm.copyWith(
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
          _buildSidebarNavItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            isSelected: true,
            onTap: () {},
          ),
          _buildSidebarNavItem(
            icon: Icons.fact_check_outlined,
            title: 'Mark Attendance',
            isSelected: false,
            onTap: widget.onMarkAttendancePressed,
          ),
          _buildSidebarNavItem(
            icon: Icons.history_toggle_off_outlined,
            title: 'Attendance History',
            isSelected: false,
            onTap: widget.onHistoryPressed,
          ),
          _buildSidebarNavItem(
            icon: Icons.event_busy_outlined,
            title: 'Leave Application',
            isSelected: false,
            onTap: widget.onLeavePressed,
          ),
          _buildSidebarNavItem(
            icon: Icons.person_outline,
            title: 'Profile & Settings',
            isSelected: false,
            onTap: () {},
          ),

          const Spacer(),

          // Active Faculty Footer Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AuthService().currentUser?.name.isNotEmpty == true
                            ? AuthService().currentUser!.name
                            : 'Dr. Rajesh Sharma',
                        style: AppTypography.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        AuthService().currentUser?.employeeId.isNotEmpty == true
                            ? 'ID: ${AuthService().currentUser!.employeeId}'
                            : 'Faculty Active',
                        style: AppTypography.labelSm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  onPressed: widget.onLogoutPressed,
                  tooltip: 'Sign Out',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: const Color(0xFF334155), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13.5,
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF818CF8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Academic Year 2024-25',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ),
                Flexible(
                  child: Text(
                    'Semester IV',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Verified',
                        style: AppTypography.labelSm.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Wed, 24 Oct 2024',
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '09:42 AM IST',
                style: AppTypography.codeSm.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          const CampusNotificationBellButton(size: 20),
          const SizedBox(width: 10),
          UserProfileAvatarButton(
            onLogout: widget.onLogoutPressed,
            size: 36,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'ERP :: FACULTY OPERATIONS',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.codeSm.copyWith(
                        color: const Color(0xFF4F46E5),
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.circle, size: 4, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Academic Session 2024-25',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.codeSm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Faculty Attendance & Overview',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  letterSpacing: -0.4,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: Color(0xFF4F46E5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Wednesday, 24 October 2024',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ACTIVE SESSION',
                    style: AppTypography.labelSm.copyWith(
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // MOBILE / COMPACT LAYOUT
  // ==========================================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFC7D2FE),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 20,
                color: Color(0xFF4338CA),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SMART CAMPUS',
                  style: AppTypography.labelSm.copyWith(
                    letterSpacing: 1.1,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  'Dashboard',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                    letterSpacing: -0.3,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const CampusNotificationBellButton(size: 21),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: UserProfileAvatarButton(
              onLogout: widget.onLogoutPressed,
            ),
          ),
        ],
      ),
      bottomNavigationBar: FacultyBottomNavigationBar(
        currentIndex: 0,
        onAttendancePressed: widget.onMarkAttendancePressed,
        onHistoryPressed: widget.onHistoryPressed,
        onLeavePressed: widget.onLeavePressed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date synced banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Wednesday, 24 Oct 2024',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Synced 12:28 PM',
                          style: AppTypography.codeSm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Profile Summary Card
            _buildProfileSummaryCard(isDesktop: false),
            const SizedBox(height: 14),

            // Geofence & Wi-Fi Policy Notice
            if (!_isNoticeDismissed) ...[
              _buildNoticeBanner(),
              const SizedBox(height: 14),
            ],

            // Daily Attendance Status Hero Card
            _buildTodayAttendanceCard(),
            const SizedBox(height: 14),

            // Campus Validation Status Chips
            _buildMobileValidationStatus(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SHARED COMPONENT WIDGETS
  // ==========================================

  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Institutional Attendance Protocol',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Please mark your attendance within campus Wi-Fi range and designated GPS boundaries.',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            color: const Color(0xFF64748B),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() => _isNoticeDismissed = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard({required bool isDesktop}) {
    final currentUser = AuthService().currentUser;
    final facultyName = currentUser?.name.isNotEmpty == true
        ? currentUser!.name
        : 'Dr. Rajesh Sharma';
    final empId = currentUser?.employeeId.isNotEmpty == true
        ? currentUser!.employeeId
        : 'SKIT-FAC-2024-8841';
    final dept = currentUser?.department.isNotEmpty == true
        ? currentUser!.department
        : 'Dept of Computer Science & Engineering';
    final desig = currentUser?.designation?.isNotEmpty == true
        ? currentUser!.designation!
        : 'HOD';

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with Online Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: isDesktop ? 68 : 56,
                    height: isDesktop ? 68 : 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEEF2FF),
                      border: Border.all(
                        color: const Color(0xFFC7D2FE),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: currentUser?.photoBase64 != null &&
                            currentUser!.photoBase64!.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              base64Decode(currentUser.photoBase64!),
                              width: isDesktop ? 68 : 56,
                              height: isDesktop ? 68 : 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person,
                                size: 36,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 36,
                            color: Color(0xFF4F46E5),
                          ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name & Department
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            facultyName,
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: isDesktop ? 19 : 17,
                              letterSpacing: -0.3,
                              color: const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFC7D2FE),
                              width: 1.1,
                            ),
                          ),
                          child: Text(
                            desig,
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4338CA),
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dept,
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF475569),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$empId • Senior Faculty Council',
                      style: AppTypography.codeSm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isDesktop) ...[
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.2),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildProfileMetaItem(
                    label: 'STAFF ID',
                    value: empId,
                    isCode: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProfileMetaItem(
                    label: 'INSTITUTIONAL EMAIL',
                    value: currentUser?.email.isNotEmpty == true
                        ? currentUser!.email
                        : '$empId@campus.edu',
                    isCode: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProfileMetaItem(
                    label: 'SCHEDULED SHIFT',
                    value: '08:30 – 16:30 IST',
                    icon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProfileMetaItem(
                    label: 'FACULTY BLOCK',
                    value: 'Turing Wing, 4th Floor',
                    icon: Icons.corporate_fare,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            size: 16,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shift',
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '08:30 – 16:30',
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.corporate_fare,
                            size: 16,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cabin',
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Turing 402',
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildProfileMetaItem({
    required String label,
    required String value,
    IconData? icon,
    bool isCode = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: isCode
                      ? AppTypography.codeSm.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: const Color(0xFF0F172A),
                        )
                      : AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: const Color(0xFF0F172A),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAttendanceCard() {
    final user = AuthService().currentUser;
    final empId = user?.employeeId ?? 'FAC-2024-CS01';
    final entries = StaffAttendanceService().getLogsForStaff(
      employeeId: empId,
      staffName: user?.name,
      department: user?.department,
    );

    AttendanceLogEntry? todayEntry;
    if (entries.isNotEmpty) {
      todayEntry = entries.firstWhere(
        (e) => e.dateTitle.toLowerCase().contains('today') || e.isLive,
        orElse: () => entries.first,
      );
    }

    final inTime = todayEntry?.checkIn ?? '08:55 AM';
    final expectedOut = (todayEntry?.checkOut != null &&
            todayEntry!.checkOut != '--:--' &&
            todayEntry.checkOut != 'In Progress')
        ? todayEntry.checkOut
        : '04:30 PM';
    final gate = todayEntry?.location ?? 'Gate A-12 Turnstile';
    final isOnDuty = todayEntry?.isLive ?? true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
          // Header with On Duty Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.event_available,
                        color: Color(0xFF4F46E5),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        "Today's Attendance Status",
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnDuty ? 'On Duty' : 'Shift Completed',
                      style: AppTypography.labelSm.copyWith(
                        color: const Color(0xFF047857),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Check-in & Expected check-out grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 360;
              final checkInCard = Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: const Icon(
                        Icons.login_rounded,
                        size: 19,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHECK-IN',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              inTime,
                              style: AppTypography.headlineSm.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.5,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        'On Time',
                        style: AppTypography.labelSm.copyWith(
                          color: const Color(0xFF047857),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              final expectedOutCard = Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 19,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPECTED OUT',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              expectedOut,
                              style: AppTypography.headlineSm.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.5,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        'Pending',
                        style: AppTypography.labelSm.copyWith(
                          color: const Color(0xFFB45309),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (isVeryNarrow) {
                return Column(
                  children: [
                    checkInCard,
                    const SizedBox(height: 10),
                    expectedOutCard,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: checkInCard),
                  const SizedBox(width: 12),
                  Expanded(child: expectedOutCard),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.2),
          const SizedBox(height: 14),

          // Turnstile Location Sync Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.door_front_door_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        gate,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_done_outlined,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ERP Synced',
                      style: AppTypography.codeSm.copyWith(
                        color: const Color(0xFF15803D),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileValidationStatus() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CAMPUS VALIDATION STATUS',
                style: AppTypography.labelSm.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Active',
                    style: AppTypography.codeSm.copyWith(
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.wifi,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wi-Fi',
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Connected',
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Range',
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Inside Boundary',
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
