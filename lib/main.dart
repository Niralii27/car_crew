import 'package:car_crew/controller/user_auth.dart';
import 'package:car_crew/screens/cartProvider.dart';
import 'package:car_crew/screens/help.dart';
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
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

//set the status bar color
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.blue[800]!, 
      statusBarIconBrightness: Brightness.light,
    ),
  );

  Get.put(UserController());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
      ],
      child: const myApp(),
    ),
  );
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
        '/selectVehicle': (context) => const HelpPage(),
        '/history': (context) => const HistroyPage(),
        '/sideNavbar': (context) => const Sidenavbar(),
      },
    );
  }
}
