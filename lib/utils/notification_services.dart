import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static FlutterLocalNotificationsPlugin get instance => _notificationsPlugin;

  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      final status = await Permission.notification.request();

      if (!status.isGranted) {
        print("Izin notifikasi tidak diberikan");
        return;
      }

      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        'task_channel',
        'Task Reminder',
        description: 'Channel untuk pengingat tugas',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings =
          InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notifikasi diklik
        },
      );

      print("Notifikasi berhasil diinisialisasi");
    } catch (e) {
      print("Error inisialisasi notifikasi: $e");
    }
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminder',
            channelDescription: 'Channel untuk notifikasi instan',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
      print('Notifikasi instan berhasil ditampilkan');
    } catch (e) {
      print('Gagal menampilkan notifikasi instan: $e');
    }
  }

  static Future<void> scheduleTaskReminder({
    required int id,
    required String tugas,
    required DateTime deadline,
  }) async {
    try {
      final h2 = deadline.subtract(const Duration(days: 2));
      if (h2.isAfter(DateTime.now())) {
        await _notificationsPlugin.zonedSchedule(
          id * 10 + 2,
          'Reminder Tugas (H-2)',
          'Tugas "$tugas" due dalam 2 hari!',
          tz.TZDateTime.from(h2, tz.local),
          _buildNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
      print('Notifikasi H-2 dijadwalkan');
    } catch (e) {
      print('Error scheduling: $e');
    }
  }

  static Future<void> scheduleTaskReminderr({
    required int id,
    required String tugas,
    required DateTime deadline,
  }) async {
    try {
      final h1 = deadline.subtract(const Duration(days: 1));
      if (h1.isAfter(DateTime.now())) {
        await _notificationsPlugin.zonedSchedule(
          id * 10 + 1,
          'Reminder Tugas (H-1)',
          'Tugas "$tugas" due dalam 1 hari!',
          tz.TZDateTime.from(h1, tz.local),
          _buildNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
      print('Notifikasi H-1 dijadwalkan');
    } catch (e) {
      print('Error scheduling: $e');
    }
  }

  static NotificationDetails _buildNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Task Reminder',
        channelDescription: 'Channel untuk pengingat tugas',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        // sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      ),
    );
  }

  static Future<void> cancelTaskNotifications(int taskId) async {
    try {
      await _notificationsPlugin.cancel(taskId * 10 + 1);
      await _notificationsPlugin.cancel(taskId * 10 + 2);
      print("Notifikasi untuk task $taskId dibatalkan");
    } catch (e) {
      print("Error membatalkan notifikasi: $e");
    }
  }

  static Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      999,
      'Test Notification',
      'Ini adalah notifikasi test',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminder',
          channelDescription: 'Channel untuk pengingat tugas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
