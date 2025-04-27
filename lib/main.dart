import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/service_one_page.dart';
import 'screens/service_two_page.dart';
import 'screens/service_three_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA1Vvd-X4oO28bVVOSByJgeV5glfM6DM6I",
      authDomain: "rasid-cam.firebaseapp.com",
      databaseURL: "https://rasid-cam-default-rtdb.firebaseio.com",
      projectId: "rasid-cam",
      storageBucket: "rasid-cam.appspot.com",
      messagingSenderId: "570394682961",
      appId: "1:570394682961:web:bdeff5621a871d60663a70",
    ),
  );
  runApp(MyApp());
}

// 1-ServiceToSeeViolationsPage --> service_see_violations
// 2-ServiceSendViolationsPage --> service_send_violations
// 3-ServiceToViewSentViolationsPage --> service_view_sent_violations
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'راصد',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        HomePage.screenRoute: (context) => const HomePage(),
        LoginPage.screenRoute: (context) => const LoginPage(),
        ServiceToSeeViolationsPage.screenRoute: (context) =>
            const ServiceToSeeViolationsPage(),
        ServiceSendViolationsPage.screenRoute: (context) =>
            const ServiceSendViolationsPage(),
        ServiceToViewSentViolationsPage.screenRoute: (context) =>
            const ServiceToViewSentViolationsPage(),
      },
      initialRoute: HomePage.screenRoute, // اجعل HomePage هي الصفحة الأولى
      // home: const LoginPage(), // تم إلغاء تعليق هذا السطر
    );
  }
}
