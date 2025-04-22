import 'dart:async';
import 'package:flutter/material.dart';
// import 'package/car_crew/settings_screen.dart';
// import 'sos_services_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late PageController _pageController;
  int currentIndex = 0;

  List<String> images = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider1.png',
  ];

  final List<Map<String, String>> services = [
    {'icon': 'assets/service_icon1.png', 'label': 'Car Service'},
    {'icon': 'assets/service_icon2.png', 'label': 'Wheel Care'},
    {'icon': 'assets/service_icon6.png', 'label': 'Painting'},
    {'icon': 'assets/service_icon3.png', 'label': 'AC Service'},
    {'icon': 'assets/service_icon7.png', 'label': 'Car Wash'},
    {'icon': 'assets/service_icon8.png', 'label': 'Battery'},
    {'icon': 'assets/service_icon4.png', 'label': 'Insurance'},
    {'icon': 'assets/service_icon5.png', 'label': 'Oiling'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = currentIndex + 1;
        if (nextPage >= images.length) {
          _pageController.jumpToPage(0);
          currentIndex = 0;
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          currentIndex = nextPage;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Welcome, Admin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/car_profile.png'),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Summary Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDashboardCard(Icons.people, 'Users', '245'),
                  _buildDashboardCard(Icons.car_repair, 'Bookings', '82'),
                  _buildDashboardCard(Icons.attach_money, 'Revenue', '₹50.2k'),
                ],
              ),

              SizedBox(height: 20),

              // Image Slider
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              // Services Grid
              Text(
                'Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          services[index]['icon']!,
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(height: 6),
                        Text(
                          services[index]['label']!,
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 20),

              // Recent Bookings
              Text(
                'Recent Bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(Icons.car_rental, color: Colors.blue),
                      title: Text('Booking #${1000 + index}'),
                      subtitle: Text('Service: Car Wash\nStatus: Completed'),
                      trailing: Text('₹799'),
                    ),
                  );
                },
              ),
              SizedBox(height: 80), // Prevent bottom nav overlap
            ],
          ),
        ),
      ),

      // 🔽 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const SosServicesScreen()),
            // );
          } else if (index == 2) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const SettingsScreen()),
            // );
          } else {
            setState(() {
              currentIndex = index;
            });
          }
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.local_car_wash), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.car_repair), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, String value) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.blue),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              Text(value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
