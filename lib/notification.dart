import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Notification
{
  static Future initialize(FlutterLocalNotificationsPlugin notPlugin) async{
    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettings = new InitializationSettings(android: androidInitialize);
    await notPlugin.initialize(initializationSettings);
  }

  static Future showBigTextNotification({var id=0, required String title, required String body,
    var payload, required FlutterLocalNotificationsPlugin fln
  }) async {
    AndroidNotificationDetails chSpecifics = new AndroidNotificationDetails(
        'some_value',
        'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var not= NotificationDetails(android: chSpecifics);
    await fln.show(0, title, body, not);
  }
}