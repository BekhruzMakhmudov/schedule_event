import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  int _normalizeId(int id) {
    const int int32Range = (1 << 31); // 2^31
    final normalized = id % int32Range;
    return normalized < 0 ? normalized + int32Range : normalized;
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Try to parse eventId from payload, fallback to notification id
    final idStr = response.payload;
    int? eventId;
    if (idStr != null) {
      final parsed = int.tryParse(idStr);
      if (parsed != null) {
        eventId = parsed;
      }
    }
    // response.id is available on Android, may be null on iOS
    eventId ??= response.id;
    if (eventId != null) {
      markAsReadByEventId(eventId);
    }
  }

  Future<void> scheduleEventReminder({
    required int eventId,
    required String eventTitle,
    required String eventDescription,
    required DateTime eventStartTime,
    required int reminderMinutes,
  }) async {
    final scheduledDate =
        eventStartTime.subtract(Duration(minutes: reminderMinutes));

    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Notifications for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      _normalizeId(eventId),
      'Upcoming Event: $eventTitle',
      'Event starts in $reminderMinutes minutes${eventDescription.isNotEmpty ? '\n$eventDescription' : ''}',
      scheduledTz,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: eventId.toString(),
    );

    // Persist as unread notification entry
    await _insertNotification(
      eventId: eventId,
      title: 'Upcoming Event: $eventTitle',
      body:
          'Event starts in $reminderMinutes minutes${eventDescription.isNotEmpty ? '\n$eventDescription' : ''}',
      scheduledAt: DateTime.now().millisecondsSinceEpoch,
      deliveredAt: scheduledDate.millisecondsSinceEpoch,
    );
  }

  Future<void> cancelNotification(int eventId) async {
    await _notifications.cancel(_normalizeId(eventId));
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ====== Persistence helpers for notifications table ======
  Future<void> _insertNotification({
    required int eventId,
    required String title,
    String? body,
    required int scheduledAt,
    required int deliveredAt,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.insert('notifications', {
      'eventId': eventId,
      'title': title,
      'body': body ?? '',
      'scheduledAt': scheduledAt,
      'deliveredAt': deliveredAt,
      'isRead': 0,
    });
  }

  Future<List<Map<String, Object?>>> getDeliveredNotifications({
    bool onlyUnread = false,
  }) async {
    final db = await AppDatabase.instance.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final whereUnread = onlyUnread ? 'AND n.isRead = 0' : '';
    // Join with events to fetch colorName for UI styling
    final rows = await db.rawQuery('''
      SELECT n.*, e.colorName
      FROM notifications n
      LEFT JOIN events e ON e.id = n.eventId
      WHERE n.deliveredAt <= ? $whereUnread
      ORDER BY n.deliveredAt DESC
    ''', [nowMs]);
    return rows;
  }

  Future<int> getUnreadCount() async {
    final db = await AppDatabase.instance.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM notifications WHERE isRead = 0 AND deliveredAt <= ?',
      [nowMs],
    );
    final cnt = Sqflite.firstIntValue(result) ?? 0;
    return cnt;
  }

  Future<void> markAsRead(int id) async {
    final db = await AppDatabase.instance.database;
    await db.update('notifications', {'isRead': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllAsRead() async {
    final db = await AppDatabase.instance.database;
    await db.update('notifications', {'isRead': 1});
  }

  Future<void> markAsReadByEventId(int eventId) async {
    final db = await AppDatabase.instance.database;
    await db.update('notifications', {'isRead': 1}, where: 'eventId = ?', whereArgs: [eventId]);
  }
}
