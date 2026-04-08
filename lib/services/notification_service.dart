import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';

/// خدمة التنبيهات المركزية لتطبيق خطوة
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── تهيئة الخدمة عند بدء التطبيق ──
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // طلب إذن الإشعارات (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // يمكن التعامل مع الضغط على الإشعار هنا
  }

  // ── جدولة تذكير يومي لعادة معينة ──
  Future<void> scheduleHabitReminder({
    required int id,
    required String habitTitle,
    required String habitIcon,
    required TimeOfDay time,
  }) async {
    await _plugin.zonedSchedule(
      id,
      '$habitIcon تذكير خطوة',
      'حان وقت: $habitTitle 💪',
      _nextInstanceOfTime(time),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'khatwa_habits',
          'تذكيرات العادات',
          channelDescription: 'إشعارات يومية لتذكيرك بعاداتك',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            'لا تنسَ: $habitTitle — كل خطوة تقربك من هدفك! 👣',
            contentTitle: '$habitIcon حان وقت عادتك',
            summaryText: 'خطوة',
          ),
          color: const Color(0xFF1D9E75),
          ledColor: const Color(0xFF1D9E75),
          ledOnMs: 1000,
          ledOffMs: 500,
          enableLights: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── إلغاء تذكير عادة معينة ──
  Future<void> cancelHabitReminder(int id) async {
    await _plugin.cancel(id);
  }

  // ── إلغاء كل التذكيرات ──
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── إرسال إشعار فوري (للاختبار) ──
  Future<void> showTestNotification(String habitTitle, String icon) async {
    await _plugin.show(
      999,
      '$icon تذكير خطوة',
      'هذا مثال على تذكير: $habitTitle',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'khatwa_habits',
          'تذكيرات العادات',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF1D9E75),
        ),
      ),
    );
  }

  // ── احسب التوقيت التالي لوقت معين ──
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

// ── نموذج إعدادات التذكير لعادة ──
class HabitReminder {
  final String habitId;
  final bool enabled;
  final int hour;
  final int minute;

  const HabitReminder({
    required this.habitId,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  HabitReminder copyWith({bool? enabled, int? hour, int? minute}) {
    return HabitReminder(
      habitId: habitId,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      };

  factory HabitReminder.fromJson(Map<String, dynamic> j) => HabitReminder(
        habitId: j['habitId'],
        enabled: j['enabled'],
        hour: j['hour'],
        minute: j['minute'],
      );

  static Future<List<HabitReminder>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('reminders');
    if (data == null) return [];
    return (jsonDecode(data) as List)
        .map((e) => HabitReminder.fromJson(e))
        .toList();
  }

  static Future<void> saveAll(List<HabitReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'reminders', jsonEncode(reminders.map((r) => r.toJson()).toList()));
  }
}
