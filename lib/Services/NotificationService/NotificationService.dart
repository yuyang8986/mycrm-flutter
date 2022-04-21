import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static BuildContext context;
  static init(BuildContext context) {
    var initilationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initilationSettingIOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(
        initilationSettingsAndroid, initilationSettingIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
    context = context;
  }

  //to use
  //  _showNotificationWithDefaultSound();

  static Future onSelectNotification(String payload) async {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: Text('Here is payload!'),
              content: Text("Payload: $payload"),
            ));
  }

  // Method 2
  static Future scheduleNotifications(ScheduleEvent event) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (!((sp.getBool("scheduleNotifications") ?? false))) {
      // await DialogService().showConfirm(context,
      //     "You have not turn on notifications on Setting, do you want to turn it on now?",
      //     () {
        sp.setBool("scheduleNotifications", true);
      //}
      //);
    }

    //   if (permissions[PermissionGroup.contacts] == PermissionStatus.granted) {
    //     await schedule(event);
    //   }
    // } else {
    // var gonnaSet = sp.getBool("scheduleNotifications");
    // if (!gonnaSet) {
    //   return;
    // }
    await schedule(event);
    //}

    //   await flutterLocalNotificationsPlugin.schedule(
    //   event.hashCode,
    //   '${event.eventType} is Overdue',
    //   '$summary',
    //   timeDue,
    //   platformChannelSpecifics,
    //   // payload: 'Default_Sound',
    // );
  }

  static Future schedule(ScheduleEvent event) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    var timeBefore = event.eventDateTime.add(Duration(minutes: -30));
    var now = DateTime.now();
    print("now is - " + now.toUtc().toString());
    // var timeDue = event.eventDateTime.add(Duration(hours: 2));
    String summary;
    switch (event.eventType.toLowerCase()) {
      case "appointment":
        summary = event.appointment.summary;
        break;
      case "event":
        summary = event.event.summary;
        break;
      case "task":
        summary = event.task.summary;
        break;
      default:
    }
    // print("notification at ${DateTime.now().add(Duration(seconds: 50))}}");

    var pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print("pending notofications :" +
        pendingNotificationRequests.length.toString());
    // return await flutterLocalNotificationsPlugin.show(
    //     0, 'plain title', 'plain body', platformChannelSpecifics,
    //     payload: 'item x');
    // return await flutterLocalNotificationsPlugin.showDailyAtTime(
    //     0, "title", "body", Time(18, 12, 0), platformChannelSpecifics);

    return await flutterLocalNotificationsPlugin.schedule(
        event.hashCode ~/ 100000,
        'Upcoming ${event.eventType} - ${DateTimeHelper.parseDateTimeToDateHHMM(event.eventDateTime)}',
        '$summary',
        timeBefore,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        payload: "'Default_Sound',");
  }
}
