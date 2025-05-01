import 'package:car_crew/screens/admin_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSidenavBar extends StatefulWidget {
  const AdminSidenavBar({Key? key}) : super(key: key);

  @override
  State<AdminSidenavBar> createState() => _SideNavbarState();
}

class _SideNavbarState extends State<AdminSidenavBar> {
  String? userId;
  String userName = "Admin";
  String userImage = "Admin";
  String userEmail = "Admin";

  final List<DrawerItem> menuItems = [
    DrawerItem(title: 'My Profile', icon: Icons.person),
    DrawerItem(title: 'Notifications', icon: Icons.notifications),
    DrawerItem(title: 'Offers & notifications', icon: Icons.local_offer),
    DrawerItem(title: 'Settings', icon: Icons.settings),
    DrawerItem(title: 'About', icon: Icons.info_outline),
    DrawerItem(title: 'Help & feedback', icon: Icons.help_outline),
  ];

  @override
  void initState() {
    super.initState();

    // Get the arguments passed from the login page
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      userId = args['userId'];
      print("User ID received: $userId");

      // Fetch user data once we have the ID
      if (userId != null) {
        fetchUserName();
      }
    }
  }

  Future<void> fetchUserName() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('UsersTbl')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['UserName'] ?? "Admin";
          userImage = userData['UserImage'] ?? "";
          userEmail = userData['UserEmail'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size to make the drawer responsive
    final screenWidth = MediaQuery.of(context).size.width;

    // Make drawer half the screen width, but with min and max constraints
    final drawerWidth = screenWidth * 0.7 < 400
        ? screenWidth * 0.7
        : screenWidth * 0.7 > 300
            ? 300.0
            : screenWidth * 0.7;

    return Drawer(
      width: drawerWidth,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // User profile header section
          _buildUserHeader(context),

          // Divider between header and navigation items
          const Divider(height: 1),

          // Navigation items
          ...menuItems.map((item) => _buildDrawerItem(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile image
          // const CircleAvatar(
          // radius: 40,
          // backgroundColor: Colors.blue,
          // child: Icon(
          //   Icons.person,
          //   size: 40,
          //   color: Colors.white,
          // ),
          // You can replace the Icon with a network image like this:/
          CircleAvatar(
            radius:
                MediaQuery.of(context).size.width * 0.1, // 10% of screen width
            backgroundColor: Colors.blue,
            backgroundImage: userImage.isNotEmpty
                ? NetworkImage(userImage)
                : AssetImage('assets/profile.png') as ImageProvider,
          ),

          const SizedBox(height: 15),

          // User name
          Text(
            userName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          // User email
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(
        item.title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: () {
        // Close drawer when item is tapped
        Navigator.pop(context);

        // Handle navigation
        if (item.title == 'My Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminProfile()),
          );
        }
        // Add your navigation logic here using setState if needed
        // Example:
        // setState(() {
        //   _selectedIndex = menuItems.indexOf(item);
        // });
        //
        // if (item.title == 'Settings') {
        //   Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => SettingsScreen()));
        // }
      },
    );
  }
}

// Model class for drawer items
class DrawerItem {
  final String title;
  final IconData icon;

  DrawerItem({required this.title, required this.icon});
}
