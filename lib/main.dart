import 'package:flutter/material.dart';
import 'package:mislab3/auth_page.dart';
import 'package:mislab3/exams.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mislab3/firebase_api.dart';
import 'package:mislab3/home.dart';
import 'calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'channel',
        channelName: 'ExamReminder',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        channelDescription: '',
      ),
    ],
  );
  AwesomeNotifications().requestPermissionToSendNotifications();
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }else if(snapshot.hasError){
          return Center(child: Text("Something went wrong!"));
        }else if(snapshot.hasData){
          return HomePage();
        }else{
          return AuthPage();
        }
      },
    ),
  );
}
