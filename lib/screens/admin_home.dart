import 'package:car_crew/screens/admin_dashboard.dart';
import 'package:car_crew/screens/admin_rating_review.dart';
import 'package:car_crew/screens/admin_services.dart';
import 'package:car_crew/screens/admin_show_booking.dart';
import 'package:car_crew/screens/history.dart';
import 'package:flutter/material.dart';
import 'package:car_crew/screens/bottom_nav_bar.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _nameState();
}

class _nameState extends State<AdminHomepage> {
  int selectedIndex = 0;

  // List of pages to display based on selected index
  final List<Widget> _pages = [
    const AdminDashboard(), // Home Page
     AdminServices(),
     AdminRatingsAndReviews(),
     AdminShowBooking(),
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
