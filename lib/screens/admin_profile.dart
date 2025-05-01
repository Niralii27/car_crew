import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Add text editing controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isEditing = false;
  Map<String, dynamic>? userData;
  String? errorMessage;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    // Dispose controllers when widget is removed
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      // Get current logged in user ID
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          errorMessage = "No user logged in";
        });
        return;
      }

      // Fetch user data from Firestore UsersTbl collection
      final DocumentSnapshot userDoc =
          await _firestore.collection('UsersTbl').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
          errorMessage = "User profile not found";
        });
        return;
      }

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>;
        _isLoading = false;

        // Set initial values for text controllers
        _nameController.text = userData?['UserName'] ?? '';
        _emailController.text = userData?['UserEmail'] ?? '';
        _phoneController.text = userData?['phoneNo'] ?? '';
        _addressController.text = userData?['address'] ?? '';
        _cityController.text = userData?['city'] ?? '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        errorMessage = "Error fetching profile: ${e.toString()}";
      });
    }
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

  Future<String> uploadImageToCloud() async {
    if (_image == null) return userData?['UserImage'] ?? '';

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
      return userData?['UserImage'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Upload image if new one was selected
      String imageUrl = await uploadImageToCloud();

      // Update user profile in Firestore with all fields
      await _firestore.collection('UsersTbl').doc(currentUser.uid).update({
        'UserImage': imageUrl,
        'UserName': _nameController.text.trim(),
        'UserEmail': _emailController.text.trim(),
        'phoneNo': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
      });

      // Also update Firebase Auth display name and email if changed
      if (_emailController.text.trim() != currentUser.email) {
        await currentUser.updateEmail(_emailController.text.trim());
      }

      if (_nameController.text.trim() != currentUser.displayName) {
        await currentUser.updateDisplayName(_nameController.text.trim());
      }

      // Refresh profile data
      await _fetchUserData();

      // Exit edit mode
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isLoading && errorMessage == null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'Cancel Editing' : 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : screenSize.width * 0.1,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: isSmallScreen ? 60.0 : 80.0,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : (userData?['UserImage'] != null
                                    ? NetworkImage(userData!['UserImage'])
                                        as ImageProvider
                                    : const AssetImage(
                                        'assets/default_profile.png')),
                            child: (userData?['UserImage'] == null &&
                                    _image == null)
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          GestureDetector(
                            onTap: _getImageFromGallery,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 20.0 : 30.0),

                      // User Name - Editable in edit mode, or display-only
                      _isEditing
                          ? _buildEditableField(
                              _nameController,
                              'Name',
                              Icons.person,
                              isSmallScreen,
                            )
                          : Text(
                              userData?['UserName'] ?? 'User',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 24.0 : 32.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      SizedBox(height: isSmallScreen ? 8.0 : 12.0),

                      // Email - Editable in edit mode, or display-only
                      _isEditing
                          ? _buildEditableField(
                              _emailController,
                              'Email',
                              Icons.email,
                              isSmallScreen,
                            )
                          : Text(
                              userData?['UserEmail'] ?? 'No email',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16.0 : 18.0,
                                color: Colors.grey[600],
                              ),
                            ),
                      SizedBox(height: isSmallScreen ? 30.0 : 40.0),

                      // User Details Card
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _isEditing
                                  ? _buildEditableField(
                                      _phoneController,
                                      'Phone Number',
                                      Icons.phone,
                                      isSmallScreen,
                                    )
                                  : _buildInfoRow(
                                      'Phone Number',
                                      userData?['phoneNo'] ?? 'Not provided',
                                      Icons.phone,
                                      isSmallScreen,
                                    ),
                              const Divider(),
                              _isEditing
                                  ? _buildEditableField(
                                      _addressController,
                                      'Address',
                                      Icons.home,
                                      isSmallScreen,
                                    )
                                  : _buildInfoRow(
                                      'Address',
                                      userData?['address'] ?? 'Not provided',
                                      Icons.home,
                                      isSmallScreen,
                                    ),
                              const Divider(),
                              _isEditing
                                  ? _buildEditableField(
                                      _cityController,
                                      'City',
                                      Icons.location_city,
                                      isSmallScreen,
                                    )
                                  : _buildInfoRow(
                                      'City',
                                      userData?['city'] ?? 'Not provided',
                                      Icons.location_city,
                                      isSmallScreen,
                                    ),
                              const Divider(),
                              _buildInfoRow(
                                'Account Created',
                                userData?['createdAt'] != null
                                    ? _formatTimestamp(userData!['createdAt'])
                                    : 'Unknown',
                                Icons.calendar_today,
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 30.0 : 40.0),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isEditing) ...[
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 24.0,
                                  vertical: isSmallScreen ? 10.0 : 16.0,
                                ),
                              ),
                            ),
                          ],
                          if (_isEditing) ...[
                            ElevatedButton.icon(
                              onPressed: _isUpdating ? null : _updateProfile,
                              icon: _isUpdating
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      padding: const EdgeInsets.all(2.0),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ))
                                  : const Icon(Icons.save),
                              label: Text(
                                  _isUpdating ? 'Updating...' : 'Save Changes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 24.0,
                                  vertical: isSmallScreen ? 10.0 : 16.0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  // Widget for displaying information in view mode
  Widget _buildInfoRow(
      String label, String value, IconData icon, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isSmallScreen ? 20.0 : 24.0, color: Colors.blue),
          SizedBox(width: isSmallScreen ? 12.0 : 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14.0 : 16.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2.0 : 4.0),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16.0 : 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for editable fields in edit mode
  Widget _buildEditableField(TextEditingController controller, String label,
      IconData icon, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: isSmallScreen ? 20.0 : 24.0, color: Colors.blue),
          SizedBox(width: isSmallScreen ? 12.0 : 16.0),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: isSmallScreen ? 8.0 : 12.0,
                ),
              ),
              style: TextStyle(
                fontSize: isSmallScreen ? 16.0 : 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    // Handle both Timestamp and DateTime objects
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Invalid date';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
