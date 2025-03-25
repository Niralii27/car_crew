import 'package:flutter/material.dart';
import 'package:car_crew/screens/loginpage.dart';

main() => runApp(
      myApp(),
    );

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'login app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loginpage(),
    );
  }
}
