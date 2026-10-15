import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Interactive Profile Avatar Button for AppBars across the Campus ERP app.
/// Tapping opens a modern session dialog displaying the active staff profile
/// and providing a prominent "Log Out & Switch ID" action.
class UserProfileAvatarButton extends StatelessWidget {
  final VoidCallback? onLogout;
  final double size;
  final EdgeInsetsGeometry padding;

  const UserProfileAvatarButton({
    super.key,
    this.onLogout,
    this.size = 32,
    this.padding = const EdgeInsets.only(right: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final tooltipText = currentUser != null
        ? 'Account: ${currentUser.name} (${currentUser.employeeId}) • Tap to View Profile or Log Out'
        : 'Profile & Session • Tap to Log Out';

    return Padding(
      padding: padding,
      child: Tooltip(
        message: tooltipText,
        child: InkWell(
          onTap: () => _showProfileDialog(context),
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: currentUser?.photoBase64 != null &&
                    currentUser!.photoBase64!.isNotEmpty
                ? ClipOval(
                    child: Image.memory(
                      base64Decode(currentUser.photoBase64!),
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.person,
                        size: size * 0.58,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: size * 0.58,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final user = AuthService().currentUser;
        final name = (user != null && user.name.trim().isNotEmpty)
            ? user.name
            : 'Faculty Member';
        final empId = (user != null && user.employeeId.trim().isNotEmpty)
            ? user.employeeId
            : 'STAFF';
        final dept = (user != null && user.department.trim().isNotEmpty)
            ? user.department
            : 'Academic Department';
        final email = (user != null && user.email.trim().isNotEmpty)
            ? user.email
            : '$empId@campus.edu';
        final role = (user?.role.toLowerCase() == 'admin')
            ? 'Campus Administrator'
            : 'Faculty Member';
        final designation = user?.designation ?? 'Academic Staff';

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.surfaceContainerLowest,
          elevation: 12,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with Title & Close Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.manage_accounts,
                                color: AppColors.primaryContainer,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Active Account',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        tooltip: 'Close',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar with verified badge
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceContainerHigh,
                            border: Border.all(
                              color: AppColors.primaryContainer
                                  .withValues(alpha: 0.4),
                              width: 2.5,
                            ),
                          ),
                          child: user?.photoBase64 != null &&
                                  user!.photoBase64!.isNotEmpty
                              ? ClipOval(
                                  child: Image.memory(
                                    base64Decode(user.photoBase64!),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.person,
                                      size: 42,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: AppColors.secondary,
                                ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name & Role Tag
                  Text(
                    name,
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$designation • $role',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Details Block (Staff ID, Dept, Email)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'STAFF ID',
                          value: empId,
                          isCode: true,
                        ),
                        const Divider(
                          height: 16,
                          color: AppColors.borderSubtle,
                        ),
                        _buildInfoRow(
                          icon: Icons.domain,
                          label: 'DEPARTMENT',
                          value: dept,
                        ),
                        const Divider(
                          height: 16,
                          color: AppColors.borderSubtle,
                        ),
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'EMAIL',
                          value: email,
                          isCode: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Primary Log Out Button
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        AuthService().signOut();
                        onLogout?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.primaryContainer,
                            behavior: SnackBarBehavior.floating,
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Logged out successfully.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isCode = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.codeSm.copyWith(
            fontSize: 10,
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: isCode
                ? AppTypography.codeSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    fontSize: 11,
                  )
                : AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    fontSize: 11,
                  ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
