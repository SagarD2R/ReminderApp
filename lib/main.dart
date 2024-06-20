import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:reminder/push_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

 SharedPreferences? prefs; // Declare as late so we can initialize later

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDxWinN-v_ziP2fYH6C8HdhxEBqTNuj1lg',
      appId: '1:437806604678:android:d1b4f11b7ba2092274cc07',
      messagingSenderId: '437806604678',
      projectId: 'reminder-9481e',
    ),
  );

  if (message.notification != null) {
    print("Handling a background message: ${message.messageId}");
    await scheduleAlarm();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDxWinN-v_ziP2fYH6C8HdhxEBqTNuj1lg',
      appId: '1:437806604678:android:d1b4f11b7ba2092274cc07',
      messagingSenderId: '437806604678',
      projectId: 'reminder-9481e',
    ),
  );



  await Alarm.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

Future<void> scheduleAlarm() async {
  final alarmSettings = AlarmSettings(
    id: 42,
    dateTime: DateTime.now(),
    assetAudioPath: 'assets/alarm.mp3',
    loopAudio: true,
    vibrate: true,
    volume: 0.8,
    fadeDuration: 3.0,
    notificationTitle: 'This is the title',
    notificationBody: 'This is the body',
    enableNotificationOnKill: true,
    androidFullScreenIntent: true,
  );
  await Alarm.set(alarmSettings: alarmSettings);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  TextEditingController _messageController = TextEditingController();
  TextEditingController _tokenController = TextEditingController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        final alarmSettings = AlarmSettings(
          id: 42,
          dateTime: DateTime.now(),
          assetAudioPath: 'assets/alarm.mp3',
          loopAudio: true,
          vibrate: true,
          volume: 0.8,
          fadeDuration: 3.0,
          notificationTitle: 'This is the title',
          notificationBody: 'This is the body',
          enableNotificationOnKill: true,
          androidFullScreenIntent: true,
        );
        await Alarm.set(alarmSettings: alarmSettings);
        print('Message also contained a notification: ${message.notification}');
        // Handle notification here
        displayNotification(
            message.notification!.title!, message.notification!.body!);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      await Alarm.stop(42);
      // Handle notification here
    });

    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> displayNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      enableVibration: true,
      // sound: RawResourceAndroidNotificationSound('default'),
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminder'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Reminder Message',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                var token = await FirebaseMessaging.instance.getToken();
                print(token);

                PushNotificationService.sendNotificationToSelectedDriver(
                    'eDCB9HvcTQWa-z-tT2XUJX:APA91bFHnMuVuFLZpls9o2INcRRvYKCAz09d4mpqlQulPGax_EIBRgQeZ24PgklMnjmUnTlgk_YbtyuoS9o85j2TLwNt5MRz3YhWqWr-KgvoS3UUmR46_JucoKxAvByh4QWfbyat7wuJ',
                    context);
                // _sendReminder();
              },
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendReminder() async {
    var token = await FirebaseMessaging.instance.getToken();
    print(token);
    // Get the reminder message and user device token
    String reminderMessage = _messageController.text;
    String userDeviceToken = _tokenController.text;

    /*// Prepare FCM message payload
    Map<String, String> message = {
      "message": {
        "token": "cvQ9bUKUQZeMPYUTGzp6ZJ:APA91bFZIn7gKesXbdlO0tpm93KhA9aPQ9Nc0K-U2YxUyrch_JzD6NznTEFCDxP0E-hM9AoFYJKvcyuMOsRGopyh-GkNYwbS7q01nQwZaH2E4HycsK4Oq2zytTxWIQj3NPMMHg1WjuAy",
        "notification": {
          "title": "Hello",
          "body": "This is testing"
        },
        "data": {
          "priority": "high",
          "sound": "app_sound.wav",
          "bodyText": "New Announcement assigned",
          "organization": "Elementary school"
        }
      }
    };
      */ /*'notification.title': 'Reminder',
      'notification.body': reminderMessage,
      // Custom data as string values
      'data.type': 'reminder',
      'data.message': reminderMessage,
      // Add any additional data fields as needed*/
/*
    try {
      // Send FCM message to the specified device token
      await FirebaseMessaging.instance.sendMessage(
          to: 'dYIHa6dRQH2obnd88fIydC:APA91bGRzT65JTPqu_NasdvaFWaboNIjz3S8WD1z8UG27dc76Sl0MiWEWb9bs3KYSrkGMmSyc4gbB1KufITPYErdhHjBxcabZ0LDE6_jWaPyW0AOewYs8YzHoRHstWqiwItEXzaeQp8q',
          data: message

      );
      // Clear the message and token fields after sending
      _messageController.clear();
      _tokenController.clear();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder set successfully!'),
        ),
      );
    } catch (e) {
      // Show error message if sending failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set reminder: $e'),
        ),
      );
    }*/

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/reminder-9481e/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  int _messageCount = 0;

  String constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token':
      " cvQ9bUKUQZeMPYUTGzp6ZJ:APA91bFZIn7gKesXbdlO0tpm93KhA9aPQ9Nc0K-U2YxUyrch_JzD6NznTEFCDxP0E-hM9AoFYJKvcyuMOsRGopyh-GkNYwbS7q01nQwZaH2E4HycsK4Oq2zytTxWIQj3NPMMHg1WjuAy",
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }
}
