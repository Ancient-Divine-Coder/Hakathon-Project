import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/campus_notification_bell_button.dart';
import '../../../core/widgets/user_profile_avatar_button.dart';
import 'admin_broadcast_message_dialog.dart';

/// Module 12: Admin Campus Broadcast & Staff Messaging Portal
/// Enables Dean, HOD, and Campus Administrators to compose and dispatch
/// campus-wide announcements, emergency alerts, or direct staff advisories.
class AdminBroadcastScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onLogoutPressed;

  const AdminBroadcastScreen({
    super.key,
    this.onBack,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
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
          onPressed: onBack,
          tooltip: 'Back',
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
                Icons.campaign_rounded,
                size: 20,
                color: Color(0xFF4F46E5),
              ),
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
                    'Broadcast & Notice Center',
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
          const CampusNotificationBellButton(size: 20),
          UserProfileAvatarButton(
            onLogout: onLogoutPressed,
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: AdminBroadcastDialogContentView(),
            ),
          ),
        ),
      ),
    );
  }
}
