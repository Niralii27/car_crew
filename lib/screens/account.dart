import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isPasswordVisible = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Function to pick image from gallery
  Future<void> _getImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        print("Fetching data for user ID: $userId");

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('UsersTbl')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          print("Document found for user: $userId");

          setState(() {
            nameController.text = userDoc['UserName'] ?? '';
            emailController.text = userDoc['UserEmail'] ?? '';
            addressController.text = userDoc['address'] ?? '';
            cityController.text = userDoc['city'] ?? '';
            phoneController.text = userDoc['phone'] ?? '';
            _profileImageUrl = userDoc['UserImage']; // Get the stored image URL
          });
        } else {
          print("User document not found for ID: $userId");
        }
      } else {
        print("User is not logged in");
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<String> uploadImageToCloud() async {
    if (_image == null) return '';

    try {
      // Initialize the Cloudinary instance with your cloud name and upload preset
      final cloudinary = CloudinaryPublic('dd8fkpbnm', 'car_Crew_images');

      // Upload file
      CloudinaryResponse response =
          await cloudinary.uploadFile(CloudinaryFile.fromFile(
        _image!.path,
        folder:
            'user_profiles', // Optional folder name in your Cloudinary account
      ));

      // Get the secure URL of the uploaded image
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return '';
    }
  }

  Future<void> saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        print("Saving profile for user ID: $userId");

        String UserImage = await uploadImageToCloud();

        await FirebaseFirestore.instance
            .collection('UsersTbl')
            .doc(userId)
            .update({
          'UserName': nameController.text,
          'UserEmail': emailController.text,
          'address': addressController.text,
          'city': cityController.text,
          'phoneNo': phoneController.text,
          if (UserImage.isNotEmpty)
            'UserImage': UserImage, // Store Cloudinary URL in 'UserImage' field
        });
        // Optionally, add a 'phone' field if you want the user to update it.
        print("Profile updated successfully with image URL: $UserImage");

        print("Profile updated successfully!");
      }
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider
                        : _profileImageUrl != null &&
                                _profileImageUrl!.isNotEmpty
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage('assets/user.jpg'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _getImageFromGallery,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Name:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Email:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Address:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                prefixIcon: Icon(Icons.home, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('City:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: 'Enter your city',
                prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Phone No:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller:
                  phoneController, // Add phoneController for the phone number
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await saveProfile();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Text('Profile updated successfully!')),
                            ],
                          ),
                          backgroundColor: Colors.blue.shade600,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: Duration(seconds: 2),
                          elevation: 8,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to change password
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Change Password',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
