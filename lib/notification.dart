import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Notification
{
  static Future initialize(FlutterLocalNotificationsPlugin notPlugin) async{
    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettings = new InitializationSettings(android: androidInitialize);
    await notPlugin.initialize(initializationSettings);
  }
}