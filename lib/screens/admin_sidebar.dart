import 'package:flutter/material.dart';

class AdminSidenavBar extends StatefulWidget {
  const AdminSidenavBar({Key? key}) : super(key: key);

  @override
  State<AdminSidenavBar> createState() => _SideNavbarState();
}

class _SideNavbarState extends State<AdminSidenavBar> {
  final List<DrawerItem> menuItems = [
    DrawerItem(title: 'My Car', icon: Icons.car_rental),
    DrawerItem(title: 'Notifications', icon: Icons.notifications),
    DrawerItem(title: 'Offers & notifications', icon: Icons.local_offer),
    DrawerItem(title: 'Settings', icon: Icons.settings),
    DrawerItem(title: 'About', icon: Icons.info_outline),
    DrawerItem(title: 'Help & feedback', icon: Icons.help_outline),
  ];

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
            backgroundImage: AssetImage('assets/profile.png'),
          ),

          const SizedBox(height: 15),

          // User name
          const Text(
            'Nirali Akbari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          // User email
          const Text(
            'akbarinirali27@gmail.com',
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
