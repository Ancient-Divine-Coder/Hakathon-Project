import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/leave_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/user_profile_avatar_button.dart';
import '../../leave/domain/models/leave_application.dart';

/// Module: Admin Leave & Duty Sanction Approval Portal
/// Allows HODs, Deans, and Campus Administrators to review pending leave
/// applications, inspect applicant quotas, and approve or reject with institutional remarks.
class AdminLeaveApprovalScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminLeaveApprovalScreen({
    super.key,
    this.onBack,
  });

  @override
  State<AdminLeaveApprovalScreen> createState() =>
      _AdminLeaveApprovalScreenState();
}

class _AdminLeaveApprovalScreenState extends State<AdminLeaveApprovalScreen> {
  final LeaveService _leaveService = LeaveService();
  String _selectedStatusFilter = 'pending'; // 'pending', 'approved', 'rejected', 'all'
  final String _selectedTypeFilter = 'all'; // 'all', 'casual', 'medical', 'onDuty', 'earned'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _reviewerName {
    final user = AuthService().currentUser;
    return (user != null && user.name.isNotEmpty)
        ? user.name
        : 'Prof. A. K. Verma (Dean Academics)';
  }

  void _handleApprove(LeaveApplication app) {
    final messenger = ScaffoldMessenger.of(context);
    final remarksController = TextEditingController(
      text: app.leaveType == LeaveType.onDuty
          ? 'Approved for official institutional duty.'
          : 'Approved as per academic council guidelines.',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approve Leave Sanction',
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Ref: ${app.id}',
                      style: AppTypography.codeSm.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.applicantName,
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${app.department} • ${app.employeeId}',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Type: ${app.leaveType.displayName} • ${app.totalDays} Day(s)',
                        style: AppTypography.codeSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Approval Remarks / Sanction Notes:',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: remarksController,
                  maxLines: 2,
                  style: AppTypography.bodySm,
                  decoration: InputDecoration(
                    hintText: 'Enter approval notes for faculty records...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final remarks = remarksController.text.trim();
                final success = await _leaveService.approveLeaveApplication(
                  applicationId: app.id,
                  reviewerName: _reviewerName,
                  remarks: remarks.isNotEmpty ? remarks : null,
                );

                if (mounted && success) {
                  setState(() {});
                  messenger.showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF059669),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Application ${app.id} for ${app.applicantName} approved successfully.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Confirm Approval'),
            ),
          ],
        );
      },
    );
  }

  void _handleReject(LeaveApplication app) {
    final messenger = ScaffoldMessenger.of(context);
    final reasonController = TextEditingController();
    String? validationError;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA), width: 1),
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disapprove Application',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Ref: ${app.id}',
                          style: AppTypography.codeSm.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Disapproving will immediately restore ${app.totalDays} day(s) back to ${app.applicantName}\'s leave balance.',
                              style: AppTypography.bodySm.copyWith(
                                color: const Color(0xFF991B1B),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rejection Reason (Mandatory):',
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      style: AppTypography.bodySm,
                      decoration: InputDecoration(
                        hintText: 'e.g. Department exam invigilation slot clash...',
                        errorText: validationError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      onChanged: (_) {
                        if (validationError != null) {
                          setDialogState(() => validationError = null);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      setDialogState(() {
                        validationError = 'Please provide an administrative reason.';
                      });
                      return;
                    }

                    Navigator.pop(dialogCtx);
                    final success = await _leaveService.rejectLeaveApplication(
                      applicationId: app.id,
                      reviewerName: _reviewerName,
                      rejectionReason: reason,
                    );

                    if (mounted && success) {
                      setState(() {});
                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Application ${app.id} disapproved. Quota restored to ${app.applicantName}.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Disapprove & Restore Quota'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = _leaveService.getAllApplications();
    final pendingCount = all.where((a) => a.status == LeaveStatus.pending).length;
    final approvedCount = all.where((a) => a.status == LeaveStatus.approved).length;
    final rejectedCount = all.where((a) => a.status == LeaveStatus.rejected).length;

    // Filter by status
    List<LeaveApplication> filtered = all;
    if (_selectedStatusFilter == 'pending') {
      filtered = filtered.where((a) => a.status == LeaveStatus.pending).toList();
    } else if (_selectedStatusFilter == 'approved') {
      filtered = filtered.where((a) => a.status == LeaveStatus.approved).toList();
    } else if (_selectedStatusFilter == 'rejected') {
      filtered = filtered.where((a) => a.status == LeaveStatus.rejected).toList();
    }

    // Filter by type
    if (_selectedTypeFilter != 'all') {
      filtered = filtered
          .where((a) => a.leaveType.name.toLowerCase() == _selectedTypeFilter.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((a) {
        return a.applicantName.toLowerCase().contains(q) ||
            a.employeeId.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q) ||
            a.reason.toLowerCase().contains(q);
      }).toList();
    }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: widget.onBack,
          tooltip: 'Back to Dashboard',
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
              child: const Icon(Icons.approval_outlined, size: 20, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CAMPUS ERP ADMIN',
                    style: AppTypography.labelSm.copyWith(
                      letterSpacing: 1.0,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Leave & Sanction Clearance',
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
          IconButton(
            icon: const Icon(Icons.sync, size: 20, color: Color(0xFF475569)),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leave requests synchronized with campus roster.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Sync Applications',
          ),
          UserProfileAvatarButton(
            onLogout: widget.onBack,
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Metrics Bento
                _buildMetricsHeader(
                  pendingCount: pendingCount,
                  approvedCount: approvedCount,
                  rejectedCount: rejectedCount,
                  totalCount: all.length,
                ),
                const SizedBox(height: 14),

                // Search & Filters Bar
                _buildSearchAndFilters(
                  pendingCount: pendingCount,
                  approvedCount: approvedCount,
                  rejectedCount: rejectedCount,
                  totalCount: all.length,
                ),
                const SizedBox(height: 14),

                // Applications List Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applications for Review (${filtered.length})',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'AY 2024-25',
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...filtered.map(_buildApplicationAdminCard),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // METRICS BENTO HEADER
  // ==========================================
  Widget _buildMetricsHeader({
    required int pendingCount,
    required int approvedCount,
    required int rejectedCount,
    required int totalCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 24) / 3;
        return Row(
          children: [
            _buildMetricTile(
              width: cardWidth,
              title: 'Pending Action',
              count: pendingCount.toString(),
              subtitle: 'Requires Review',
              badgeColor: const Color(0xFFD97706),
              icon: Icons.hourglass_top_outlined,
              isSelected: _selectedStatusFilter == 'pending',
              onTap: () => setState(() => _selectedStatusFilter = 'pending'),
            ),
            const SizedBox(width: 12),
            _buildMetricTile(
              width: cardWidth,
              title: 'Approved',
              count: approvedCount.toString(),
              subtitle: 'Sanctions Granted',
              badgeColor: const Color(0xFF059669),
              icon: Icons.check_circle_outline,
              isSelected: _selectedStatusFilter == 'approved',
              onTap: () => setState(() => _selectedStatusFilter = 'approved'),
            ),
            const SizedBox(width: 12),
            _buildMetricTile(
              width: cardWidth,
              title: 'Disapproved',
              count: rejectedCount.toString(),
              subtitle: 'Duty Maintained',
              badgeColor: AppColors.error,
              icon: Icons.cancel_outlined,
              isSelected: _selectedStatusFilter == 'rejected',
              onTap: () => setState(() => _selectedStatusFilter = 'rejected'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile({
    required double width,
    required String title,
    required String count,
    required String subtitle,
    required Color badgeColor,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? badgeColor : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? badgeColor.withValues(alpha: 0.15)
                    : const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: isSelected ? 8 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: AppTypography.labelSm.copyWith(
                        color: isSelected ? badgeColor : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: badgeColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  count,
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: isSelected ? badgeColor : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelSm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SEARCH & FILTER BAR
  // ==========================================
  Widget _buildSearchAndFilters({
    required int pendingCount,
    required int approvedCount,
    required int rejectedCount,
    required int totalCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Search by Faculty Name, Staff ID, Department, or Reason...',
              hintStyle: AppTypography.bodySm.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('pending', 'Pending Review ($pendingCount)'),
                const SizedBox(width: 8),
                _buildStatusChip('approved', 'Approved ($approvedCount)'),
                const SizedBox(width: 8),
                _buildStatusChip('rejected', 'Disapproved ($rejectedCount)'),
                const SizedBox(width: 8),
                _buildStatusChip('all', 'All Applications ($totalCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String key, String label) {
    final isSelected = _selectedStatusFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
  // APPLICATION ADMIN CARD
  // ==========================================
  Widget _buildApplicationAdminCard(LeaveApplication app) {
    final balance = _leaveService.getLeaveBalance(app.employeeId);

    Color statusColor;
    IconData statusIcon;
    switch (app.status) {
      case LeaveStatus.approved:
        statusColor = const Color(0xFF059669);
        statusIcon = Icons.check_circle_outline;
        break;
      case LeaveStatus.pending:
        statusColor = const Color(0xFFD97706);
        statusIcon = Icons.hourglass_top_outlined;
        break;
      case LeaveStatus.rejected:
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_outlined;
        break;
      case LeaveStatus.cancelled:
        statusColor = const Color(0xFF64748B);
        statusIcon = Icons.block_outlined;
        break;
    }

    final startDateStr = '${app.startDate.day} ${_monthName(app.startDate.month)} ${app.startDate.year}';
    final endDateStr = '${app.endDate.day} ${_monthName(app.endDate.month)} ${app.endDate.year}';
    final dateDisplay = app.startDate == app.endDate
        ? startDateStr
        : '$startDateStr – $endDateStr';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: app.status == LeaveStatus.pending
              ? const Color(0xFFFDE68A)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
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
          // Applicant Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    app.applicantName.isNotEmpty ? app.applicantName[0] : 'F',
                    style: AppTypography.headlineSm.copyWith(
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.applicantName,
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${app.department} • ${app.employeeId}',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
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

          // Leave Specs Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                      ),
                      child: Text(
                        app.leaveType.shortCode,
                        style: AppTypography.codeSm.copyWith(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      app.leaveType.displayName,
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      dateDisplay,
                      style: AppTypography.codeSm.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${app.totalDays} Day${app.totalDays > 1 ? 's' : ''}',
                        style: AppTypography.codeSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Applicant Balance Snapshot
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Faculty Quota: CL: ${balance.casualLeaveRemaining.toStringAsFixed(0)}/${balance.casualLeaveTotal.toStringAsFixed(0)} • ML: ${balance.medicalLeaveRemaining.toStringAsFixed(0)}/${balance.medicalLeaveTotal.toStringAsFixed(0)} • OD Logged: ${balance.onDutyLeaveUsed.toStringAsFixed(0)}',
                  style: AppTypography.labelSm.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Purpose / Reason
          Text(
            'Justification: ${app.reason}',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF334155),
              fontSize: 12,
            ),
          ),

          if (app.attachmentUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 14, color: Color(0xFF4F46E5)),
                const SizedBox(width: 4),
                Text(
                  'Attachment: ${app.attachmentUrl}',
                  style: AppTypography.codeSm.copyWith(
                    color: const Color(0xFF4F46E5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],

          // Approval or Rejection Remarks if already processed
          if (app.status == LeaveStatus.approved && app.approvedBy != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sanctioned by ${app.approvedBy} on ${app.reviewedAt != null ? "${app.reviewedAt!.day} ${_monthName(app.reviewedAt!.month)} ${app.reviewedAt!.year}" : "Official Record"}',
                      style: AppTypography.codeSm.copyWith(
                        color: const Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (app.status == LeaveStatus.rejected) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, size: 14, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Text(
                        'Disapproved by ${app.approvedBy ?? "Dean / HOD Administration"}',
                        style: AppTypography.codeSm.copyWith(
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (app.rejectionReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reason: ${app.rejectionReason}',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF991B1B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Decision Action Buttons if Pending
          if (app.status == LeaveStatus.pending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
                      backgroundColor: const Color(0xFFFEF2F2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleReject(app),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Disapprove'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleApprove(app),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Approve Sanction'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          const Icon(Icons.fact_check_outlined, size: 40, color: Color(0xFF64748B)),
          const SizedBox(height: 12),
          Text(
            'No applications found',
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All leave applications in this category have been processed or none match the active filter.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
