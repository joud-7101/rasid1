import 'package:flutter/material.dart';
import 'home_page.dart'; // تأكد من استيراد صفحة HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String screenRoute = 'login_signup_screen';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول / التسجيل'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة HomePage
            Navigator.pushNamed(context, HomePage.screenRoute);
          },
          child: Text(
            'اضغط هنا للدخول',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF161616),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
