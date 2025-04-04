import 'package:flutter/material.dart';
import 'package:car_crew/screens/bottom_nav_bar.dart';
import 'package:car_crew/screens/homecontent.dart';
import 'package:car_crew/screens/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _nameState();
}

class _nameState extends State<Homepage> {
  int selectedIndex = 0;

  // List of pages to display based on selected index
  final List<Widget> _pages = [
    const HomeContent(), // Home Page
    const ServicesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex], // Selected Page Dikhega
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
