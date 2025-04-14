import 'package:car_crew/screens/sideNavbar.dart';
import 'package:flutter/material.dart';
import 'package:car_crew/screens/loginpage.dart';
import 'package:car_crew/screens/account.dart';
import 'package:car_crew/screens/cardetail.dart';
import 'package:car_crew/screens/help.dart';
import 'package:car_crew/screens/sideNavbar.dart';
import 'package:car_crew/screens/history.dart';

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
      routes: {
        '/account': (context) => const AccountPage(),
        '/carDetails': (context) => const CarDetailPage(),
        '/help': (context) => const HelpPage(),
        '/history': (context) => const HistroyPage(),
        '/sideNavbar': (context) => const Sidenavbar(),
      },
    );
  }
}
