import 'package:car_crew/controller/user_auth.dart';
import 'package:car_crew/screens/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_crew/controller/snackbar_controller.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  String userName = "User";
  String userImage = "User";
  String createdat = "User";

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
          // Replace 'UserName' with whatever field you use in your Firestore
          userName = userData['UserName'] ?? "User";
          userImage = userData['UserImage'] ?? "";
          createdat = userData['UserEmail'] ?? "User";
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Snackbar _snackbar = Snackbar();

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
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: userImage.isNotEmpty
                            ? NetworkImage(userImage)
                            : AssetImage('assets/user.png') as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          SizedBox(height: 6),
                          Text(createdat, style: TextStyle(color: Colors.grey)),
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
                optionTile(context, 'Help', Icons.help_outline, primaryBlue,
                    '/selectVehicle'),
                optionTile(context, 'Services History', Icons.history,
                    primaryBlue, '/history'),
                optionTile(
                    context, 'Support', Icons.headset_mic, primaryBlue, ''),
                optionTile(context, 'About Us', Icons.info, primaryBlue,
                    '/sideNavbar'),
                const SizedBox(height: 10),
                optionTile(
                  context,
                  'Log out',
                  Icons.logout,
                  Colors.redAccent,
                  '',
                  onTap: () async {
                    try {
                      await UserController.logout();

                      if (!context.mounted) return;

                      _snackbar.showCustomSnackBar(
                        context: context,
                        message: "Logged out successfully",
                        isSuccess: true,
                      );

                      Get.offAll(() =>
                          const loginpage()); // This also removes current context
                    } catch (e) {
                      if (!context.mounted) return;

                      _snackbar.showCustomSnackBar(
                        context: context,
                        message: "Failed to logout: ${e.toString()}",
                        isSuccess: false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget optionTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String routeName, {
    VoidCallback? onTap, // ✅ Optional custom action
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap ??
            (routeName.isNotEmpty
                ? () {
                    Navigator.pushNamed(context, routeName);
                  }
                : null),
      ),
    );
  }
}
