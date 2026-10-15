import 'package:flutter/material.dart';
import '../../../core/services/campus_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Opens the Admin Broadcast & Messaging Composer as a modal sheet or dialog.
void showAdminBroadcastDialog(
  BuildContext context, {
  String? prefillRecipient,
  String? prefillTitle,
}) {
  final isDesktop = MediaQuery.of(context).size.width >= 768;

  if (isDesktop) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          width: 620,
          height: 720,
          child: AdminBroadcastDialogContentView(
            prefillRecipient: prefillRecipient,
            prefillTitle: prefillTitle,
            isDialog: true,
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (context, scrollController) => AdminBroadcastDialogContentView(
          scrollController: scrollController,
          prefillRecipient: prefillRecipient,
          prefillTitle: prefillTitle,
          isDialog: false,
        ),
      ),
    );
  }
}

class AdminBroadcastDialogContentView extends StatefulWidget {
  final ScrollController? scrollController;
  final String? prefillRecipient;
  final String? prefillTitle;
  final bool isDialog;

  const AdminBroadcastDialogContentView({
    super.key,
    this.scrollController,
    this.prefillRecipient,
    this.prefillTitle,
    this.isDialog = true,
  });

  @override
  State<AdminBroadcastDialogContentView> createState() =>
      _AdminBroadcastDialogContentViewState();
}

class _AdminBroadcastDialogContentViewState
    extends State<AdminBroadcastDialogContentView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _customRecipientController =
      TextEditingController();

  NotificationCategory _selectedCategory = NotificationCategory.academic;
  String _selectedAudience = 'All Campus Faculty & Staff';
  bool _isUrgent = false;
  bool _isSending = false;

  final List<String> _audienceOptions = [
    'All Campus Faculty & Staff',
    'Teaching Faculty Only',
    'Technical & Lab Staff',
    'Administrative Staff',
    'Computer Science & Engg Dept',
    'Mechanical Engineering Dept',
    'Electronics & Comm Dept',
    'Custom / Direct Staff Recipient',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.prefillTitle != null) {
      _titleController.text = widget.prefillTitle!;
    }
    if (widget.prefillRecipient != null) {
      _selectedAudience = 'Custom / Direct Staff Recipient';
      _customRecipientController.text = widget.prefillRecipient!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _customRecipientController.dispose();
    super.dispose();
  }

  void _applyTemplate({
    required String title,
    required String body,
    required NotificationCategory category,
    required String audience,
    bool isUrgent = false,
  }) {
    setState(() {
      _titleController.text = title;
      _bodyController.text = body;
      _selectedCategory = category;
      _selectedAudience = audience;
      _isUrgent = isUrgent;
    });
  }

  Future<void> _handleSendBroadcast() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an announcement title.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write the announcement message content.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final audience = _selectedAudience == 'Custom / Direct Staff Recipient'
        ? (_customRecipientController.text.trim().isNotEmpty
            ? _customRecipientController.text.trim()
            : 'Direct Recipient')
        : _selectedAudience;

    setState(() => _isSending = true);

    try {
      final notifService = CampusNotificationService();
      await notifService.sendBroadcastMessage(
        title: title,
        description: body,
        category: _selectedCategory,
        targetAudience: audience,
        sender: 'Campus System Administrator (HQ)',
        isUrgent: _isUrgent,
      );

      if (!mounted) return;

      setState(() {
        _isSending = false;
        _titleController.clear();
        _bodyController.clear();
        _customRecipientController.clear();
        _isUrgent = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Broadcast sent to $audience!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Switch to Sent tab to show confirmation
      _tabController.animateTo(1);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to dispatch broadcast: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: widget.isDialog
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle for bottom sheet
          if (!widget.isDialog)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Broadcast Center',
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Send announcements, circulars & direct notices',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.secondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_note_rounded, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Compose',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Sent Notices',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildComposeTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposeTab() {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Templates Section
          Text(
            'QUICK ANNOUNCEMENT PRESETS',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip(
                  label: '⚡ Biometric Rescan',
                  title: 'Biometric Terminal Recalibration',
                  body:
                      'Facial biometric turnstiles at Main Academic Block undergoing maintenance. Please complete check-in at Block B.',
                  category: NotificationCategory.biometric,
                  audience: 'All Campus Faculty & Staff',
                ),
                const SizedBox(width: 8),
                _buildPresetChip(
                  label: '🏛️ Faculty Meeting',
                  title: 'Academic Council Emergency Meeting',
                  body:
                      'All department heads and faculty members are requested to convene in Conference Hall A at 03:00 PM today.',
                  category: NotificationCategory.academic,
                  audience: 'Teaching Faculty Only',
                ),
                const SizedBox(width: 8),
                _buildPresetChip(
                  label: '📅 Leave Deadline',
                  title: 'Semester Break Leave Filing Advisory',
                  body:
                      'Submit all Casual and Earned Leave applications for the upcoming recess period by Friday 05:00 PM.',
                  category: NotificationCategory.leave,
                  audience: 'All Campus Faculty & Staff',
                ),
                const SizedBox(width: 8),
                _buildPresetChip(
                  label: '🚨 Network Maintenance',
                  title: 'Campus Wi-Fi & Gateway Upgrade',
                  body:
                      'Scheduled network maintenance tonight from 11:00 PM to 02:00 AM. Biometric offline caching will remain active.',
                  category: NotificationCategory.system,
                  audience: 'All Campus Faculty & Staff',
                  isUrgent: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Target Audience
          Text(
            'TARGET AUDIENCE',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAudience,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                items: _audienceOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(
                      opt,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAudience = val);
                },
              ),
            ),
          ),

          if (_selectedAudience == 'Custom / Direct Staff Recipient') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customRecipientController,
              decoration: InputDecoration(
                labelText: 'Specific Staff ID or Name',
                hintText: 'e.g. Dr. Rajesh Sharma (SKIT-FAC-2024-8841)',
                prefixIcon: const Icon(Icons.person_pin_rounded, size: 20),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Category Selector
          Text(
            'MESSAGE CATEGORY',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(
                NotificationCategory.academic,
                'Academic / Circular',
                Icons.school_rounded,
                AppColors.primary,
              ),
              _buildCategoryChip(
                NotificationCategory.biometric,
                'Biometrics & Roster',
                Icons.face_retouching_natural_rounded,
                const Color(0xFF059669),
              ),
              _buildCategoryChip(
                NotificationCategory.leave,
                'Leave & Policy',
                Icons.event_available_rounded,
                const Color(0xFFD97706),
              ),
              _buildCategoryChip(
                NotificationCategory.system,
                'System & Alert',
                Icons.dns_rounded,
                const Color(0xFF0284C7),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Priority / Urgent Flag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _isUrgent
                  ? const Color(0xFFFEE2E2)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isUrgent
                    ? const Color(0xFFEF4444)
                    : AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isUrgent ? Icons.error_rounded : Icons.info_outline_rounded,
                  color: _isUrgent ? const Color(0xFFDC2626) : AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'High Priority Alert',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _isUrgent
                              ? const Color(0xFFB91C1C)
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Highlight in red and pin as urgent in recipient feed',
                        style: AppTypography.codeSm.copyWith(
                          fontSize: 11,
                          color: _isUrgent
                              ? const Color(0xFFDC2626)
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isUrgent,
                  activeThumbColor: const Color(0xFFDC2626),
                  onChanged: (val) => setState(() => _isUrgent = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Announcement Title
          Text(
            'ANNOUNCEMENT TITLE',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'e.g. Faculty Senate Special Session',
              prefixIcon: const Icon(Icons.title_rounded, size: 20),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Announcement Body
          Text(
            'MESSAGE CONTENT',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _bodyController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Enter detailed circular description, instructions, or venue directions...',
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 20),

          // Live Preview Card
          if (_titleController.text.isNotEmpty || _bodyController.text.isNotEmpty) ...[
            Text(
              'LIVE RECIPIENT PREVIEW',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isUrgent
                    ? const Color(0xFFFEF2F2)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isUrgent
                      ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                      : AppColors.outlineVariant.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isUrgent
                          ? const Color(0xFFFEE2E2)
                          : AppColors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isUrgent
                          ? Icons.crisis_alert_rounded
                          : Icons.campaign_rounded,
                      color: _isUrgent
                          ? const Color(0xFFDC2626)
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _titleController.text.isEmpty
                                    ? 'Announcement Title'
                                    : _titleController.text,
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Just now',
                                style: AppTypography.codeSm.copyWith(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bodyController.text.isEmpty
                              ? 'Your message text will appear here for all recipients.'
                              : _bodyController.text,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'From: Campus System Administrator • Audience: $_selectedAudience',
                          style: AppTypography.codeSm.copyWith(
                            fontSize: 10,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _titleController.clear();
                      _bodyController.clear();
                      _customRecipientController.clear();
                      _isUrgent = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _handleSendBroadcast,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isSending ? 'Sending...' : 'Dispatch Announcement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final notifService = CampusNotificationService();

    return ValueListenableBuilder<List<CampusNotification>>(
      valueListenable: notifService.sentBroadcastsNotifier,
      builder: (context, sentList, _) {
        if (sentList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 30,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No Sent Broadcasts Yet',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use the Compose tab to dispatch announcements to faculty and staff.',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: sentList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = sentList[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.isUrgent
                    ? const Color(0xFFFEF2F2)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isUrgent
                      ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                      : AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.containerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: AppTypography.bodySm.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (item.isUrgent)
                                  Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'URGENT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Text(
                                  item.timestamp,
                                  style: AppTypography.codeSm.copyWith(
                                    fontSize: 10,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurface.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.groups_rounded,
                              size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            item.targetAudience,
                            style: AppTypography.codeSm.copyWith(
                              fontSize: 11,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _applyTemplate(
                                title: item.title,
                                body: item.description,
                                category: item.category,
                                audience: item.targetAudience,
                                isUrgent: item.isUrgent,
                              );
                              _tabController.animateTo(0);
                            },
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text('Re-use'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18),
                            color: const Color(0xFFDC2626),
                            tooltip: 'Revoke Notice',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              notifService.deleteSentBroadcast(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notice revoked and removed.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String title,
    required String body,
    required NotificationCategory category,
    required String audience,
    bool isUrgent = false,
  }) {
    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelSm.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(
        color: AppColors.outlineVariant.withValues(alpha: 0.7),
      ),
      onPressed: () {
        _applyTemplate(
          title: title,
          body: body,
          category: category,
          audience: audience,
          isUrgent: isUrgent,
        );
      },
    );
  }

  Widget _buildCategoryChip(
    NotificationCategory category,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.onSurface,
      ),
      selectedColor: color,
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? color : AppColors.outlineVariant.withValues(alpha: 0.6),
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedCategory = category);
      },
    );
  }
}
