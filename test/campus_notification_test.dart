import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_erp/core/services/campus_notification_service.dart';
import 'package:campus_erp/core/widgets/campus_notification_bell_button.dart';
import 'package:campus_erp/features/admin/presentation/admin_broadcast_message_dialog.dart';
import 'package:campus_erp/features/admin/presentation/campus_attendance_management_screen.dart';

void main() {
  group('CampusNotificationService Unit Tests', () {
    late CampusNotificationService service;

    setUp(() {
      service = CampusNotificationService();
      service.resetForTesting();
    });

    test('Initializes with default campus notifications and unread count', () {
      expect(service.notifications.isNotEmpty, isTrue);
      expect(service.unreadCount, equals(3));
      expect(service.unreadCountNotifier.value, equals(3));
      expect(service.notificationsNotifier.value.length, equals(5));
      expect(service.sentBroadcasts.length, equals(1));
    });

    test('markAsRead updates item status and decreases unread count', () {
      service.markAsRead('notif_1');
      expect(service.unreadCount, equals(2));
      final item = service.notifications.firstWhere((n) => n.id == 'notif_1');
      expect(item.isRead, isTrue);
    });

    test('markAllAsRead marks all notifications as read', () {
      service.markAllAsRead();
      expect(service.unreadCount, equals(0));
      expect(service.unreadCountNotifier.value, equals(0));
      for (final n in service.notifications) {
        expect(n.isRead, isTrue);
      }
    });

    test('addNotification adds an unread notification to the top of the list', () {
      final initialCount = service.notifications.length;
      final initialUnread = service.unreadCount;

      service.addNotification(
        title: 'Emergency Lab Alert',
        description: 'Server room power maintenance scheduled.',
        category: NotificationCategory.system,
      );

      expect(service.notifications.length, equals(initialCount + 1));
      expect(service.unreadCount, equals(initialUnread + 1));
      expect(service.notifications.first.title, equals('Emergency Lab Alert'));
      expect(service.notifications.first.isRead, isFalse);
    });

    test('removeNotification deletes target item and recalculates unread', () {
      service.removeNotification('notif_1');
      expect(service.notifications.any((n) => n.id == 'notif_1'), isFalse);
      expect(service.unreadCount, equals(2));
    });

    test('clearAll clears all notifications', () {
      service.clearAll();
      expect(service.notifications.isEmpty, isTrue);
      expect(service.unreadCount, equals(0));
    });

    test('sendBroadcastMessage adds notice to notifications and sentBroadcasts', () async {
      final initialUnread = service.unreadCount;
      final initialSent = service.sentBroadcasts.length;

      final notif = await service.sendBroadcastMessage(
        title: 'Holiday Advisory',
        description: 'Campus closed on Friday for Founder Day celebration.',
        category: NotificationCategory.academic,
        targetAudience: 'All Campus Faculty & Staff',
        isUrgent: false,
      );

      expect(service.unreadCount, equals(initialUnread + 1));
      expect(service.sentBroadcasts.length, equals(initialSent + 1));
      expect(service.notifications.first.id, equals(notif.id));
      expect(service.sentBroadcasts.first.id, equals(notif.id));
      expect(notif.targetAudience, equals('All Campus Faculty & Staff'));
    });

    test('sendBroadcastMessage with isUrgent flags item with urgent icon and color', () async {
      final notif = await service.sendBroadcastMessage(
        title: 'Flash Flood Warning',
        description: 'Heavy precipitation advisory. Evening lectures suspended.',
        category: NotificationCategory.system,
        isUrgent: true,
      );

      expect(notif.isUrgent, isTrue);
      expect(notif.icon, equals(Icons.emergency_rounded));
    });

    test('deleteSentBroadcast removes notice from both sent and notification lists', () async {
      final notif = await service.sendBroadcastMessage(
        title: 'Draft Notice',
        description: 'To be revoked immediately.',
        category: NotificationCategory.academic,
      );

      expect(service.notifications.any((n) => n.id == notif.id), isTrue);
      expect(service.sentBroadcasts.any((n) => n.id == notif.id), isTrue);

      service.deleteSentBroadcast(notif.id);

      expect(service.notifications.any((n) => n.id == notif.id), isFalse);
      expect(service.sentBroadcasts.any((n) => n.id == notif.id), isFalse);
    });
  });

  group('CampusNotificationBellButton Widget Tests', () {
    late CampusNotificationService service;

    setUp(() {
      service = CampusNotificationService();
      service.resetForTesting();
    });

    testWidgets('Renders bell button with unread count badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: SafeArea(
                child: Row(
                  children: [
                    CampusNotificationBellButton(size: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CampusNotificationBellButton), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Tapping bell button opens Campus Notification Center sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CampusNotificationBellButton(size: 22),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CampusNotificationBellButton));
      await tester.pumpAndSettle();

      expect(find.text('Campus Notifications'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      expect(find.text('Biometric Attendance Verified'), findsOneWidget);
      expect(find.text('Campus Geofence Active'), findsOneWidget);
      expect(find.text('Leave Sanction Approved'), findsOneWidget);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(service.unreadCount, equals(0));
    });

    testWidgets('Shows empty state when clear all is tapped', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      service.clearAll();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CampusNotificationBellButton(size: 22),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('3'), findsNothing);

      await tester.tap(find.byType(CampusNotificationBellButton));
      await tester.pumpAndSettle();

      expect(find.text('All caught up!'), findsOneWidget);
      expect(
        find.text('No active campus announcements or activity alerts right now.'),
        findsOneWidget,
      );
    });
  });

  group('Admin Broadcast & Messaging Widget Tests', () {
    late CampusNotificationService service;

    setUp(() {
      service = CampusNotificationService();
      service.resetForTesting();
    });

    testWidgets('Admin can compose and dispatch a campus announcement', (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminBroadcastDialogContentView(isDialog: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Admin Broadcast Center'), findsOneWidget);
      expect(find.text('Compose'), findsOneWidget);
      expect(find.text('Sent Notices'), findsOneWidget);

      // Tap preset '⚡ Biometric Rescan'
      await tester.tap(find.text('⚡ Biometric Rescan'));
      await tester.pumpAndSettle();

      // Title & message are populated (in text field and in preview)
      expect(find.text('Biometric Terminal Recalibration'), findsWidgets);

      // Tap 'Dispatch Announcement'
      await tester.tap(find.text('Dispatch Announcement'));
      await tester.pumpAndSettle();

      // Verify notification service received the broadcast
      expect(service.notifications.first.title, equals('Biometric Terminal Recalibration'));
      expect(service.unreadCount, equals(4)); // 3 default + 1 new broadcast

      // Verify automatically switched to 'Sent Notices' tab
      expect(find.text('Biometric Terminal Recalibration'), findsWidgets);
    });

    testWidgets('CampusAttendanceManagementScreen provides broadcast actions', (tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool broadcastCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CampusAttendanceManagementScreen(
            onBroadcast: () {
              broadcastCalled = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Broadcast icon in AppBar
      expect(find.byTooltip('Send Campus Announcement / Broadcast'), findsOneWidget);

      // Verify Broadcast button above roster
      expect(find.text('Broadcast'), findsOneWidget);

      // Tap broadcast button
      await tester.tap(find.text('Broadcast'));
      await tester.pumpAndSettle();

      expect(broadcastCalled, isTrue);
    });

    testWidgets('Admin can open direct staff notice from attendance details modal', (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: CampusAttendanceManagementScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the first staff card (Dr. Rajesh Sharma)
      await tester.tap(find.text('Dr. Rajesh Sharma'));
      await tester.pumpAndSettle();

      // 'Send Notice' button is present in the modal
      expect(find.text('Send Notice'), findsOneWidget);

      // Tap 'Send Notice'
      await tester.tap(find.text('Send Notice'));
      await tester.pumpAndSettle();

      // Admin Broadcast Center opens with prefilled details
      expect(find.text('Admin Broadcast Center'), findsOneWidget);
      expect(find.text('Dr. Rajesh Sharma (SKIT-FAC-2024-8841)'), findsOneWidget);
    });
  });
}
