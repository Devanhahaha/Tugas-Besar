import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
      static FlutterLocalNotificationsPlugin get instance => _notificationsPlugin;


  static Future<void> initialize() async {
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

  await _notificationsPlugin.initialize(settings);

  // Ganti cara minta izin dengan permission_handler
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
  static Future<void> scheduleTaskReminder({
    required int id,
    required String tugas,
    required DateTime deadline,
  }) async {
    // Jadwalkan H-2
    final DateTime h2 = deadline.subtract(const Duration(days: 2));
    if (h2.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        id * 10 + 2, // ID unik
        'Reminder Tugas (H-2)',
        'Tugas "$tugas" due dalam 2 hari!',
        tz.TZDateTime.from(h2, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminder',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }

    // Jadwalkan H-1
    final DateTime h1 = deadline.subtract(const Duration(days: 1));
    if (h1.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        id * 10 + 1,
        'Reminder Tugas (H-1)',
        'Tugas "$tugas" due besok!',
        tz.TZDateTime.from(h1, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminder',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  static Future<void> cancelTaskNotifications(int taskId) async {
    await _notificationsPlugin.cancel(taskId * 10 + 1);
    await _notificationsPlugin.cancel(taskId * 10 + 2);
  }
}
