import 'package:car_crew/screens/sideNavbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:car_crew/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:car_crew/screens/loginpage.dart';
import 'package:car_crew/screens/account.dart';
import 'package:car_crew/screens/cardetail.dart';
import 'package:car_crew/screens/selectVehicle.dart';
import 'package:car_crew/screens/sideNavbar.dart';
import 'package:car_crew/screens/history.dart';
import 'package:get/get.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'login app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loginpage(),
      routes: {
        '/account': (context) => const AccountPage(),
        '/carDetails': (context) => const CarDetailPage(),
        '/selectVehicle': (context) => const Selectvehicle(),
        '/history': (context) => const HistroyPage(),
        '/sideNavbar': (context) => const Sidenavbar(),
      },
    );
  }
}
