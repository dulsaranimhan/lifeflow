import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../features/notifications/domain/reminder_plan.dart';

/// Schedules LifeFlow's reminders as phone notifications (Android first).
class ReminderService {
  ReminderService._();

  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'lifeflow_reminders',
    'Reminders',
    channelDescription: 'Deadlines, events and time-to-leave alerts',
    importance: Importance.high,
    priority: Priority.high,
  );

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Sets up time zones and the plugin. Safe to call more than once.
  Future<void> init() async {
    if (_ready || !_supported) return;
    tz_data.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Colombo'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  /// Asks for the Android 13+ notification permission.
  Future<void> requestPermission() async {
    if (!_ready) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Replaces all scheduled reminders with [reminders].
  Future<void> sync(List<PlannedReminder> reminders) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.time, tz.local),
        notificationDetails: const NotificationDetails(android: _channel),
        // Inexact alarms need no extra permission; a few minutes of drift
        // is fine for reminders.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Removes every scheduled reminder (e.g. on sign out).
  Future<void> clear() async {
    if (_ready) await _plugin.cancelAll();
  }
}
