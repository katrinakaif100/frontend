import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi notifikasi
  Future<void> initialize() async {
    // Memastikan data zona waktu di-load
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Menjadwalkan notifikasi
  Future<void> scheduleNotification(
      DateTime scheduledTime, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // channel id
      'your_channel_name', // channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Mengonversi DateTime menjadi TZDateTime
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    // Menjadwalkan notifikasi
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID notifikasi
      title, // Judul
      body, // Isi notifikasi
      scheduledDate, // Waktu yang dijadwalkan
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode:
          AndroidScheduleMode.exact, // Mode penjadwalan yang disarankan
      payload: 'item x',
    );
  }

  // Menampilkan notifikasi
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'notification', // channel id
      'pemberitahuan', // channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID notifikasi
      title, // Judul
      body, // Isi notifikasi
      platformChannelSpecifics,
      payload: 'item x', // Payload untuk data tambahan jika diperlukan
    );
  }
}
