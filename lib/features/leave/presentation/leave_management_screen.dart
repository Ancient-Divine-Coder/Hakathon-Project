import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/leave_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/campus_notification_bell_button.dart';
import '../../../core/widgets/faculty_bottom_navigation_bar.dart';
import '../../../core/widgets/user_profile_avatar_button.dart';
import '../domain/models/leave_application.dart';
import '../domain/models/leave_balance.dart';

/// Module: Leave & Sanction Management Screen
/// Displays faculty leave balances, active sanctions, and provides a streamlined
/// application interface for Casual, Medical, On-Duty, and Earned leaves.
class LeaveManagementScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  final VoidCallback? onDashboardPressed;
  final VoidCallback? onAttendancePressed;
  final VoidCallback? onHistoryPressed;
  final VoidCallback? onLogoutPressed;

  const LeaveManagementScreen({
    super.key,
    this.onBackToDashboard,
    this.onDashboardPressed,
    this.onAttendancePressed,
    this.onHistoryPressed,
    this.onLogoutPressed,
  });

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'

  String get _currentEmployeeId {
    final user = AuthService().currentUser;
    return (user != null && user.employeeId.isNotEmpty)
        ? user.employeeId
        : 'FAC-2024-CS01';
  }

  String get _currentFacultyName {
    final user = AuthService().currentUser;
    return (user != null && user.name.isNotEmpty)
        ? user.name
        : 'Dr. Rajesh Sharma';
  }

  String get _currentDepartment {
    final user = AuthService().currentUser;
    return (user != null && user.department.isNotEmpty)
        ? user.department
        : 'Computer Science & Engineering';
  }

  void _showApplyLeaveModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ApplyLeaveBottomSheet(
        employeeId: _currentEmployeeId,
        applicantName: _currentFacultyName,
        department: _currentDepartment,
        onApplicationSubmitted: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empId = _currentEmployeeId;
    final balance = LeaveService().getLeaveBalance(empId);
    final allApplications = LeaveService().getLeaveApplications(empId);

    final filteredApplications = allApplications.where((app) {
      if (_selectedFilter == 'pending') return app.status == LeaveStatus.pending;
      if (_selectedFilter == 'approved') return app.status == LeaveStatus.approved;
      if (_selectedFilter == 'rejected') return app.status == LeaveStatus.rejected;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.2),
          child: Divider(height: 1.2, thickness: 1.2, color: Color(0xFFE2E8F0)),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                size: 20,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMART CAMPUS',
                    style: AppTypography.labelSm.copyWith(
                      letterSpacing: 1.0,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Leave & Sanctions',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Faculty Profile Banner
                _buildFacultyBanner(),
                const SizedBox(height: 16),

                // Annual Leave Balance Quotas
                _buildLeaveBalanceSection(balance),
                const SizedBox(height: 16),

                // Quick Action: Apply for Leave
                _buildApplyLeaveButton(),
                const SizedBox(height: 18),

                // Filter Pills & Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Application History',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${filteredApplications.length} Record${filteredApplications.length == 1 ? '' : 's'}',
                      style: AppTypography.labelSm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFilterHeader(allApplications),
                const SizedBox(height: 14),

                // Applications List
                if (filteredApplications.isEmpty)
                  _buildEmptyState()
                else
                  Column(
                    children: filteredApplications.map((app) {
                      return _buildApplicationCard(app);
                    }).toList(),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FacultyBottomNavigationBar(
        currentIndex: 3,
        onDashboardPressed: widget.onDashboardPressed ?? widget.onBackToDashboard,
        onAttendancePressed: widget.onAttendancePressed,
        onHistoryPressed: widget.onHistoryPressed,
        onLeavePressed: () {},
      ),
    );
  }

  // ==========================================
  // FACULTY BANNER
  // ==========================================
  Widget _buildFacultyBanner() {
    final user = AuthService().currentUser;
    final empId = (user != null && user.employeeId.isNotEmpty)
        ? user.employeeId
        : 'CS-4092';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.badge_rounded,
              size: 24,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentFacultyName,
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'FACULTY ID #$empId • $_currentDepartment',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
            ),
            child: Text(
              'AY 2024-25',
              style: AppTypography.codeSm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: const Color(0xFF4F46E5),
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LEAVE BALANCE QUOTAS GRID
  // ==========================================
  Widget _buildLeaveBalanceSection(LeaveBalance balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leave Balances & Quota',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Academic Session 2024',
                style: AppTypography.labelSm.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 550;
            return GridView.count(
              crossAxisCount: isDesktop ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isDesktop ? 1.35 : 1.38,
              children: [
                _buildQuotaTile(
                  code: 'CL',
                  title: 'Casual Leave',
                  remaining: balance.casualLeaveRemaining,
                  total: balance.casualLeaveTotal,
                  accentColor: const Color(0xFF4F46E5),
                  accentBg: const Color(0xFFEEF2FF),
                ),
                _buildQuotaTile(
                  code: 'ML',
                  title: 'Medical Leave',
                  remaining: balance.medicalLeaveRemaining,
                  total: balance.medicalLeaveTotal,
                  accentColor: const Color(0xFF0284C7),
                  accentBg: const Color(0xFFE0F2FE),
                ),
                _buildQuotaTile(
                  code: 'OD',
                  title: 'On-Duty Logged',
                  remaining: balance.onDutyLeaveUsed,
                  total: 0,
                  isAccumulated: true,
                  accentColor: const Color(0xFFD97706),
                  accentBg: const Color(0xFFFEF3C7),
                ),
                _buildQuotaTile(
                  code: 'CO',
                  title: 'Comp-Off Balance',
                  remaining: balance.compOffBalance,
                  total: 5.0,
                  accentColor: const Color(0xFF059669),
                  accentBg: const Color(0xFFECFDF5),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuotaTile({
    required String code,
    required String title,
    required double remaining,
    required double total,
    required Color accentColor,
    required Color accentBg,
    bool isAccumulated = false,
  }) {
    final progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 1.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: AppTypography.codeSm.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm.copyWith(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  remaining.toStringAsFixed(remaining.truncateToDouble() == remaining ? 0 : 1),
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (!isAccumulated && total > 0)
                  Text(
                    ' / ${total.toStringAsFixed(0)} Days',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    ' Days',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (!isAccumulated && total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            )
          else
            Text(
              'Institutional Sanctions',
              style: AppTypography.labelSm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // APPLY LEAVE BUTTON
  // ==========================================
  Widget _buildApplyLeaveButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _showApplyLeaveModal,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
        label: Text(
          'Apply for Leave / Duty Sanction',
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FILTER BAR
  // ==========================================
  Widget _buildFilterHeader(List<LeaveApplication> all) {
    final pendingCount = all.where((a) => a.status == LeaveStatus.pending).length;
    final approvedCount = all.where((a) => a.status == LeaveStatus.approved).length;
    final rejectedCount = all.where((a) => a.status == LeaveStatus.rejected).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('all', 'All (${all.length})'),
          const SizedBox(width: 8),
          _buildFilterChip('pending', 'Pending ($pendingCount)'),
          const SizedBox(width: 8),
          _buildFilterChip('approved', 'Approved ($approvedCount)'),
          const SizedBox(width: 8),
          _buildFilterChip('rejected', 'Rejected ($rejectedCount)'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = filterKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
  // APPLICATION CARDS
  // ==========================================
  Widget _buildApplicationCard(LeaveApplication app) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    switch (app.status) {
      case LeaveStatus.approved:
        statusColor = const Color(0xFF059669);
        statusBg = const Color(0xFFECFDF5);
        statusIcon = Icons.check_circle_rounded;
        break;
      case LeaveStatus.pending:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case LeaveStatus.rejected:
        statusColor = const Color(0xFFDC2626);
        statusBg = const Color(0xFFFEF2F2);
        statusIcon = Icons.cancel_rounded;
        break;
      case LeaveStatus.cancelled:
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
        statusIcon = Icons.block_rounded;
        break;
    }

    final startDateStr = '${app.startDate.day} ${_monthName(app.startDate.month)} ${app.startDate.year}';
    final endDateStr = '${app.endDate.day} ${_monthName(app.endDate.month)} ${app.endDate.year}';
    final dateDisplay = app.startDate == app.endDate
        ? startDateStr
        : '$startDateStr - $endDateStr';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  app.leaveType.displayName,
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5),
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.25), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      app.status.displayName,
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                dateDisplay,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${app.totalDays} Day${app.totalDays > 1 ? 's' : ''}',
                  style: AppTypography.codeSm.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            app.reason,
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF334155),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (app.approvedBy != null || app.attachmentUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  if (app.approvedBy != null) ...[
                    const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        app.approvedBy!,
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (app.attachmentUrl != null) ...[
                    const Icon(Icons.attach_file_rounded, size: 15, color: Color(0xFF64748B)),
                    const SizedBox(width: 3),
                    Text(
                      'Document attached',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (app.status == LeaveStatus.pending) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await LeaveService().cancelLeaveApplication(app.id, _currentEmployeeId);
                  setState(() {});
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Leave application cancelled.')),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Cancel Request', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available_outlined, size: 24, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          Text(
            'No leave applications under this filter.',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[(month - 1).clamp(0, 11)];
  }
}

/// Bottom sheet dialog for applying for leave
class _ApplyLeaveBottomSheet extends StatefulWidget {
  final String employeeId;
  final String applicantName;
  final String department;
  final VoidCallback onApplicationSubmitted;

  const _ApplyLeaveBottomSheet({
    required this.employeeId,
    required this.applicantName,
    required this.department,
    required this.onApplicationSubmitted,
  });

  @override
  State<_ApplyLeaveBottomSheet> createState() => _ApplyLeaveBottomSheetState();
}

class _ApplyLeaveBottomSheetState extends State<_ApplyLeaveBottomSheet> {
  LeaveType _selectedType = LeaveType.casual;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  final TextEditingController _reasonController = TextEditingController();
  bool _isHalfDay = false;
  bool _isSubmitting = false;

  double get _calculatedDays {
    if (_isHalfDay) return 0.5;
    final diff = _endDate.difference(_startDate).inDays;
    return (diff + 1).toDouble().clamp(1.0, 90.0);
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please state the purpose / reason for leave.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final app = LeaveApplication(
      id: 'LV-${DateTime.now().millisecondsSinceEpoch}',
      employeeId: widget.employeeId,
      applicantName: widget.applicantName,
      department: widget.department,
      leaveType: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      totalDays: _calculatedDays,
      reason: reason,
      status: LeaveStatus.pending,
      appliedAt: DateTime.now(),
    );

    await LeaveService().submitLeaveApplication(app);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    widget.onApplicationSubmitted();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF059669),
        content: Text('Leave application for ${_selectedType.displayName} submitted for approval.'),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apply for Leave / Duty Sanction',
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 20),
                const SizedBox(height: 8),

                // Leave Type Dropdown
                Text(
                  'Leave Type',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<LeaveType>(
                      value: _selectedType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      items: LeaveType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.displayName,
                            style: AppTypography.bodyMd.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Date Pickers
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2024, 1, 1),
                                lastDate: DateTime(2026, 12, 31),
                              );
                              if (picked != null) {
                                setState(() {
                                  _startDate = picked;
                                  if (_endDate.isBefore(_startDate)) {
                                    _endDate = _startDate;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: _startDate,
                                lastDate: DateTime(2026, 12, 31),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Half Day Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isHalfDay,
                      activeColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() => _isHalfDay = val ?? false);
                      },
                    ),
                    const Text(
                      'Half Day Leave (0.5 Day)',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Total: $_calculatedDays Day${_calculatedDays == 1.0 ? '' : 's'}',
                        style: AppTypography.codeSm.copyWith(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Reason Text Input
                Text(
                  'Reason / Justification',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Attending academic conference, medical rest, or urgent domestic matter...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Submit Leave Application',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

