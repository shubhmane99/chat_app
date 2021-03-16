import 'package:flutter/material.dart';
import 'Pages/LoginPage.dart';
import 'Pages/LoginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Telegram Clone',
        theme: ThemeData(
          primaryColor: Colors.lightBlueAccent,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'Coding Cafe',
              style: TextStyle(
                  fontSize: 26.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          body: LoginScreen(),
        ));
  }
}
