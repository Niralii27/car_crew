import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    const Color primaryBlue = Color(0xFF007BFF);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: deviceWidth * 0.06,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: deviceHeight * 0.03),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // User Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage('assets/user.jpg'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Felicia Lopez',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          SizedBox(height: 6),
                          Text('Joined Sep 2020',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Account and Car Menu Section
                optionTile(
                    context, 'Account', Icons.person, primaryBlue, '/account'),
                optionTile(context, 'Car Profile', Icons.directions_car,
                    primaryBlue, '/carDetails'),
                optionTile(
                    context, 'Help', Icons.help_outline, primaryBlue, '/help'),
                optionTile(context, 'Services History', Icons.history,
                    primaryBlue, '/history'),
                optionTile(
                    context, 'Support', Icons.headset_mic, primaryBlue, ''),
                optionTile(context, 'About Us', Icons.info, primaryBlue,
                    '/sideNavbar'),
                const SizedBox(height: 10),
                optionTile(
                    context, 'Log out', Icons.logout, Colors.redAccent, ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget optionTile(BuildContext context, String title, IconData icon,
      Color color, String routeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
        leading: Icon(icon, color: color),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: routeName.isNotEmpty
            ? () {
                Navigator.pushNamed(context, routeName);
              }
            : null,
      ),
    );
  }
}
