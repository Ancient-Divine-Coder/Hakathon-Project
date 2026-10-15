import 'package:flutter/material.dart';
import '../services/campus_notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Interactive Bell Ring Notification Button for AppBars across Campus ERP.
/// Features a dynamic unread counter badge and opens a full notifications modal
/// on mobile or dialog on desktop.
class CampusNotificationBellButton extends StatelessWidget {
  final double size;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const CampusNotificationBellButton({
    super.key,
    this.size = 22,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    final notifService = CampusNotificationService();

    return Padding(
      padding: padding,
      child: ValueListenableBuilder<int>(
        valueListenable: notifService.unreadCountNotifier,
        builder: (context, unreadCount, _) {
          return Tooltip(
            message: unreadCount > 0
                ? '$unreadCount unread campus notifications • Tap to view'
                : 'Campus Notifications',
            child: InkWell(
              onTap: () => showCampusNotifications(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      unreadCount > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      size: size,
                      color: color ?? AppColors.onSurface,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444), // Crimson unread badge
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.surface,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Displays the campus notification center as a bottom sheet (mobile) or dialog (desktop).
void showCampusNotifications(BuildContext context) {
  final isDesktop = MediaQuery.of(context).size.width >= 768;

  if (isDesktop) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          width: 520,
          height: 640,
          child: _CampusNotificationsSheet(isDialog: true),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _CampusNotificationsSheet(
          scrollController: scrollController,
          isDialog: false,
        ),
      ),
    );
  }
}

class _CampusNotificationsSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final bool isDialog;

  const _CampusNotificationsSheet({
    this.scrollController,
    required this.isDialog,
  });

  @override
  State<_CampusNotificationsSheet> createState() =>
      _CampusNotificationsSheetState();
}

class _CampusNotificationsSheetState extends State<_CampusNotificationsSheet> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final notifService = CampusNotificationService();

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
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
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

          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Campus Notifications',
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: notifService.unreadCountNotifier,
                            builder: (context, unread, _) {
                              if (unread == 0) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '$unread new',
                                  style: const TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Text(
                        'Campus & Faculty Live Stream',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    notifService.markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('Mark all read'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Unread'),
                const SizedBox(width: 8),
                _buildFilterChip('Biometrics'),
                const SizedBox(width: 8),
                _buildFilterChip('Leaves'),
                const SizedBox(width: 8),
                _buildFilterChip('Academic'),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Notification List
          Expanded(
            child: ValueListenableBuilder<List<CampusNotification>>(
              valueListenable: notifService.notificationsNotifier,
              builder: (context, notifs, _) {
                final filtered = notifs.where((n) {
                  if (_selectedFilter == 'Unread') return !n.isRead;
                  if (_selectedFilter == 'Biometrics') {
                    return n.category == NotificationCategory.biometric;
                  }
                  if (_selectedFilter == 'Leaves') {
                    return n.category == NotificationCategory.leave;
                  }
                  if (_selectedFilter == 'Academic') {
                    return n.category == NotificationCategory.academic;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_off_outlined,
                              size: 32,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            notifs.isEmpty
                                ? 'All caught up!'
                                : (_selectedFilter == 'Unread'
                                    ? 'No unread notifications'
                                    : 'No notifications in this filter'),
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notifs.isEmpty
                                ? 'No active campus announcements or activity alerts right now.'
                                : 'You are completely caught up with this stream!',
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildNotificationCard(item, notifService);
                  },
                );
              },
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              borderRadius: widget.isDialog
                  ? const BorderRadius.vertical(bottom: Radius.circular(24))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<List<CampusNotification>>(
                  valueListenable: notifService.notificationsNotifier,
                  builder: (context, notifs, _) {
                    return Text(
                      '${notifs.length} total messages',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    notifService.clearAll();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = label);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    CampusNotification item,
    CampusNotificationService service,
  ) {
    return InkWell(
      onTap: () {
        service.markAsRead(item.id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppColors.surface
              : item.containerColor.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? AppColors.outlineVariant.withValues(alpha: 0.5)
                : item.color.withValues(alpha: 0.4),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.containerColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right side: unread dot & dismiss button
            Column(
              children: [
                if (!item.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.color,
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                InkWell(
                  onTap: () {
                    service.removeNotification(item.id);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
