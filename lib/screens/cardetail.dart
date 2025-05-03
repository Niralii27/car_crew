import 'package:car_crew/screens/selectVehicle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CarDetailPage extends StatefulWidget {
  final String? userId;
  const CarDetailPage({super.key, this.userId});

  @override
  _CarDetailPageState createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  TextEditingController modelController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController numberplateController = TextEditingController();

  // Variables to store selected product data
  String? selectedProductId;
  String? selectedImageUrl;
  bool isLoading = true;
  bool isNewProfile = true;
  String? userId; // Store userId locally

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Get the userId from Firebase Authentication, then from widget property, then from Get arguments
    userId = FirebaseAuth.instance.currentUser?.uid;

    // If Firebase Auth doesn't have a user, try widget or Get arguments as fallback
    if (userId == null || userId!.isEmpty) {
      userId = widget.userId ?? Get.arguments?['userId'];
    }

    // Debugging info
    print('DEBUG: userId from Auth: ${FirebaseAuth.instance.currentUser?.uid}');
    print('DEBUG: userId from widget: ${widget.userId}');
    print('DEBUG: userId from Get.arguments: ${Get.arguments?['userId']}');
    print('DEBUG: Final userId being used: $userId');

    _loadCarProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show any error messages after the widget is fully built
    if (errorMessage != null) {
      // Using a small delay to ensure the widget is fully built
      Future.delayed(Duration.zero, () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage!)),
          );
          errorMessage = null;
        }
      });
    }
  }

  Future<void> _loadCarProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (userId != null && userId!.isNotEmpty) {
        final carProfileDoc = await FirebaseFirestore.instance
            .collection('carProfile')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (carProfileDoc.docs.isNotEmpty) {
          final carData = carProfileDoc.docs.first.data();
          setState(() {
            modelController.text = carData['model'] ?? 'Default Model';
            companyController.text = carData['company'] ?? 'Default Company';
            colorController.text = carData['color'] ?? 'Default Color';
            numberplateController.text = carData['numberplate'] ?? '';
            selectedImageUrl = carData['imageUrl'];
            selectedProductId = carData['productId'];
            isNewProfile = false;
          });
        } else {
          // Set default values if no car profile exists
          setState(() {
            modelController.text = 'Default Model';
            companyController.text = 'Default Company';
            colorController.text = 'Default Color';
            numberplateController.text = '';
            isNewProfile = true;
          });
        }
      } else {
        // Handle case when userId is null or empty
        print(
            'DEBUG: userId is null or empty. widget.userId: ${widget.userId}, Get.arguments: ${Get.arguments}');
        errorMessage = 'User ID not found. Please login again.';

        // Try to get userId one more time directly from FirebaseAuth
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          userId = currentUser.uid;
          print('DEBUG: Recovered userId from Firebase Auth: $userId');
          // Try again with the recovered userId
          _loadCarProfile();
          return; // Exit this method as we're calling it again
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      errorMessage = 'Error loading profile: $e';
      // Set default values on error as well
      setState(() {
        modelController.text = 'Default Model';
        companyController.text = 'Default Company';
        colorController.text = 'Default Color';
        numberplateController.text = '';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveCarProfile() async {
    // First check if we already have a userId
    if (userId == null || userId!.isEmpty) {
      // Try to get userId from FirebaseAuth as a last resort
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userId = currentUser.uid;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User not logged in. Please login first.')),
        );
        return;
      }
    }

    try {
      final carProfileData = {
        'userId': userId,
        'model': modelController.text,
        'company': companyController.text,
        'color': colorController.text,
        'numberplate': numberplateController.text,
        'productId': selectedProductId,
        'imageUrl': selectedImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isNewProfile) {
        // Insert new profile
        carProfileData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('carProfile')
            .add(carProfileData);
        setState(() {
          isNewProfile = false;
        });
      } else {
        // Update existing profile
        final carProfileDoc = await FirebaseFirestore.instance
            .collection('carProfile')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (carProfileDoc.docs.isNotEmpty) {
          await carProfileDoc.docs.first.reference.update(carProfileData);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Car profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openSelectVehicle(bool isCompany) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Selectvehicle(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (isCompany) {
          companyController.text = result['categoryName'] ?? '';
        }
        modelController.text = result['productName'] ?? '';
        selectedProductId = result['productId'];
        selectedImageUrl = result['imageUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Vehicle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo[600],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.indigo[600],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top curved container with car image
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.indigo[600],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _openSelectVehicle(false),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'carImage',
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  image: selectedImageUrl != null
                                      ? DecorationImage(
                                          image:
                                              NetworkImage(selectedImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: selectedImageUrl == null
                                    ? Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: Colors.indigo[300],
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedImageUrl != null
                                  ? 'Change Vehicle'
                                  : 'Select Your Vehicle',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Form content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Field
                        _buildFormField(
                          label: 'Company',
                          controller: companyController,
                          icon: Icons.business,
                          isSelectable: true,
                          onTap: () => _openSelectVehicle(true),
                        ),

                        const SizedBox(height: 20),

                        // Model Field
                        _buildFormField(
                          label: 'Model',
                          controller: modelController,
                          icon: Icons.directions_car,
                          isSelectable: true,
                          onTap: () => _openSelectVehicle(false),
                        ),

                        const SizedBox(height: 20),

                        // Color Field
                        _buildFormField(
                          label: 'Color',
                          controller: colorController,
                          icon: Icons.color_lens,
                        ),

                        const SizedBox(height: 20),

                        // Number Plate Field
                        _buildFormField(
                          label: 'License Plate',
                          controller: numberplateController,
                          icon: Icons.credit_card,
                          capitalization: TextCapitalization.characters,
                        ),

                        const SizedBox(height: 40),

                        // Save Button
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveCarProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[600],
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: Colors.indigo.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: const Text(
                                'SAVE PROFILE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isSelectable = false,
    VoidCallback? onTap,
    TextCapitalization capitalization = TextCapitalization.sentences,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        InkWell(
          onTap: isSelectable ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              enabled: !isSelectable,
              textCapitalization: capitalization,
              decoration: InputDecoration(
                hintText: 'Enter ${label.toLowerCase()}',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.indigo[600],
                    size: 22,
                  ),
                ),
                suffixIcon: isSelectable
                    ? Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.indigo[300],
                        size: 16,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.indigo[200]!,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
