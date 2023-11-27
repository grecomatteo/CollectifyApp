import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notification {
  static Future initialize(FlutterLocalNotificationsPlugin notPlugin) async {
    var iosInitialize = const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true);

    var androidInitialize = const AndroidInitializationSettings(
      'mipmap/ic_launcher',
    );
    var initializationSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iosInitialize);
    await notPlugin.initialize(initializationSettings);
  }

  static Future showBigTextNotification(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails chSpecifics = AndroidNotificationDetails(
      'some_value',
      'channel_name',
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      importance: Importance.max,
      priority: Priority.high,
    );

    var not = NotificationDetails(android: chSpecifics);
    await fln.show(0, title, body, not);
  }
}
