import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum NotificationCategory {
  biometric,
  academic,
  leave,
  system,
}

class CampusNotification {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final NotificationCategory category;
  final IconData icon;
  final Color color;
  final Color containerColor;
  final String targetAudience;
  final String sender;
  final bool isUrgent;
  final DateTime? sentAt;
  bool isRead;

  CampusNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.icon,
    required this.color,
    required this.containerColor,
    this.targetAudience = 'All Campus Faculty & Staff',
    this.sender = 'Campus Administration',
    this.isUrgent = false,
    this.sentAt,
    this.isRead = false,
  });

  CampusNotification copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    NotificationCategory? category,
    IconData? icon,
    Color? color,
    Color? containerColor,
    String? targetAudience,
    String? sender,
    bool? isUrgent,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return CampusNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      containerColor: containerColor ?? this.containerColor,
      targetAudience: targetAudience ?? this.targetAudience,
      sender: sender ?? this.sender,
      isUrgent: isUrgent ?? this.isUrgent,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Singleton manager for live faculty campus notifications and admin messaging
class CampusNotificationService {
  static final CampusNotificationService _instance =
      CampusNotificationService._internal();

  factory CampusNotificationService() => _instance;

  CampusNotificationService._internal() {
    _initDefaultNotifications();
  }

  final List<CampusNotification> _notifications = [];
  final List<CampusNotification> _sentBroadcasts = [];

  final ValueNotifier<List<CampusNotification>> notificationsNotifier =
      ValueNotifier<List<CampusNotification>>([]);
  final ValueNotifier<List<CampusNotification>> sentBroadcastsNotifier =
      ValueNotifier<List<CampusNotification>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  void _initDefaultNotifications() {
    final defaults = [
      CampusNotification(
        id: 'notif_1',
        title: 'Biometric Attendance Verified',
        description:
            'Facial recognition check-in confirmed via MobileFaceNet at LT-04 Hall terminal.',
        timestamp: '5m ago',
        category: NotificationCategory.biometric,
        icon: Icons.face_retouching_natural_rounded,
        color: const Color(0xFF059669),
        containerColor: const Color(0xFFD1FAE5),
        targetAudience: 'Self',
        sender: 'Biometric Engine HQ',
        isRead: false,
      ),
      CampusNotification(
        id: 'notif_2',
        title: 'Campus Geofence Active',
        description:
            'GPS boundary sync successful • 99.4% signal lock within Academic Block.',
        timestamp: '25m ago',
        category: NotificationCategory.system,
        icon: Icons.location_on_rounded,
        color: const Color(0xFF0284C7),
        containerColor: const Color(0xFFE0F2FE),
        targetAudience: 'All Faculty & Staff',
        sender: 'Network & Security Cell',
        isRead: false,
      ),
      CampusNotification(
        id: 'notif_3',
        title: 'Leave Sanction Approved',
        description:
            'Casual Leave request for 24 Oct approved by Department Head with quota balance updated.',
        timestamp: '1h ago',
        category: NotificationCategory.leave,
        icon: Icons.event_available_rounded,
        color: const Color(0xFFD97706),
        containerColor: const Color(0xFFFEF3C7),
        targetAudience: 'Self',
        sender: 'HoD & Dean Office',
        isRead: false,
      ),
      CampusNotification(
        id: 'notif_4',
        title: 'Upcoming Lecture Schedule',
        description:
            'Operating Systems & Architecture Lab scheduled at 10:30 AM in CS Lab 2.',
        timestamp: '2h ago',
        category: NotificationCategory.academic,
        icon: Icons.school_rounded,
        color: AppColors.primary,
        containerColor: AppColors.primaryContainer.withValues(alpha: 0.15),
        targetAudience: 'Teaching Faculty',
        sender: 'Academic Senate Registrar',
        isRead: true,
      ),
      CampusNotification(
        id: 'notif_5',
        title: 'Academic Senate Notice',
        description:
            'Mid-term evaluation grade submissions portal opens next Monday. Ensure course marks are finalized.',
        timestamp: 'Yesterday',
        category: NotificationCategory.academic,
        icon: Icons.campaign_rounded,
        color: const Color(0xFF7C3AED),
        containerColor: const Color(0xFFEDE9FE),
        targetAudience: 'All Teaching Faculty',
        sender: 'Campus System Administrator',
        isRead: true,
      ),
    ];

    _notifications.addAll(defaults);

    // Initial broadcast history for admin visibility
    _sentBroadcasts.add(defaults[4]); // The Academic Senate Notice
    _notifyChanges();
  }

  List<CampusNotification> get notifications => List.unmodifiable(_notifications);
  List<CampusNotification> get sentBroadcasts => List.unmodifiable(_sentBroadcasts);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Sends a broadcast message or circular from Administrator to faculty/staff
  Future<CampusNotification> sendBroadcastMessage({
    required String title,
    required String description,
    required NotificationCategory category,
    String targetAudience = 'All Campus Faculty & Staff',
    String sender = 'Campus System Administrator',
    bool isUrgent = false,
  }) async {
    IconData resolvedIcon = isUrgent ? Icons.crisis_alert_rounded : Icons.campaign_rounded;
    Color resolvedColor = isUrgent ? const Color(0xFFDC2626) : AppColors.primary;
    Color resolvedContainer = isUrgent
        ? const Color(0xFFFEE2E2)
        : AppColors.primaryContainer.withValues(alpha: 0.15);

    if (category == NotificationCategory.biometric) {
      resolvedIcon = isUrgent ? Icons.warning_rounded : Icons.face_retouching_natural_rounded;
      resolvedColor = const Color(0xFF059669);
      resolvedContainer = const Color(0xFFD1FAE5);
    } else if (category == NotificationCategory.leave) {
      resolvedIcon = Icons.event_note_rounded;
      resolvedColor = const Color(0xFFD97706);
      resolvedContainer = const Color(0xFFFEF3C7);
    } else if (category == NotificationCategory.system) {
      resolvedIcon = isUrgent ? Icons.emergency_rounded : Icons.dns_rounded;
      resolvedColor = isUrgent ? const Color(0xFFDC2626) : const Color(0xFF0284C7);
      resolvedContainer = isUrgent ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE);
    }

    final notif = CampusNotification(
      id: 'broadcast_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      timestamp: 'Just now',
      category: category,
      icon: resolvedIcon,
      color: resolvedColor,
      containerColor: resolvedContainer,
      targetAudience: targetAudience,
      sender: sender,
      isUrgent: isUrgent,
      sentAt: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notif);
    _sentBroadcasts.insert(0, notif);
    _notifyChanges();

    // Persist to Firestore if cloud connection is active
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('campus_announcements').add({
          'id': notif.id,
          'title': notif.title,
          'description': notif.description,
          'category': category.name,
          'targetAudience': targetAudience,
          'sender': sender,
          'isUrgent': isUrgent,
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('[CampusNotificationService] Firestore broadcast error: $e');
      }
    }

    return notif;
  }

  void addNotification({
    required String title,
    required String description,
    required NotificationCategory category,
    IconData? icon,
    Color? color,
    Color? containerColor,
    String targetAudience = 'All Campus Faculty & Staff',
    String sender = 'Campus Administration',
    bool isUrgent = false,
  }) {
    IconData resolvedIcon = icon ?? Icons.notifications_active_rounded;
    Color resolvedColor = color ?? AppColors.primary;
    Color resolvedContainer =
        containerColor ?? AppColors.primaryContainer.withValues(alpha: 0.15);

    if (category == NotificationCategory.biometric) {
      resolvedIcon = Icons.face_retouching_natural_rounded;
      resolvedColor = const Color(0xFF059669);
      resolvedContainer = const Color(0xFFD1FAE5);
    } else if (category == NotificationCategory.leave) {
      resolvedIcon = Icons.event_available_rounded;
      resolvedColor = const Color(0xFFD97706);
      resolvedContainer = const Color(0xFFFEF3C7);
    } else if (category == NotificationCategory.system) {
      resolvedIcon = Icons.info_rounded;
      resolvedColor = const Color(0xFF0284C7);
      resolvedContainer = const Color(0xFFE0F2FE);
    }

    final notif = CampusNotification(
      id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      timestamp: 'Just now',
      category: category,
      icon: resolvedIcon,
      color: resolvedColor,
      containerColor: resolvedContainer,
      targetAudience: targetAudience,
      sender: sender,
      isUrgent: isUrgent,
      sentAt: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notif);
    _notifyChanges();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _notifyChanges();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      _notifyChanges();
    }
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notifyChanges();
  }

  void deleteSentBroadcast(String id) {
    _sentBroadcasts.removeWhere((n) => n.id == id);
    _notifications.removeWhere((n) => n.id == id);
    _notifyChanges();
  }

  void clearAll() {
    _notifications.clear();
    _notifyChanges();
  }

  void resetForTesting() {
    _notifications.clear();
    _sentBroadcasts.clear();
    _initDefaultNotifications();
  }

  void _notifyChanges() {
    notificationsNotifier.value = List.unmodifiable(_notifications);
    sentBroadcastsNotifier.value = List.unmodifiable(_sentBroadcasts);
    unreadCountNotifier.value = unreadCount;
  }
}
