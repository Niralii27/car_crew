import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddCategory extends StatefulWidget {
  const AdminAddCategory({Key? key}) : super(key: key);

  @override
  State<AdminAddCategory> createState() => _AdminAddCategoryState();
}

class _AdminAddCategoryState extends State<AdminAddCategory> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Image preview state
  bool _isValidImageUrl = false;
  bool _isPreviewLoading = false;

  // Key for form validation
  final _formKey = GlobalKey<FormState>();

  // Check if the image URL is valid
  void _validateImageUrl() {
    setState(() {
      _isPreviewLoading = true;
    });

    // Simple validation for common image extensions
    final url = _imageUrlController.text.trim();
    final isValidFormat = url.startsWith('http') &&
        (url.endsWith('.jpg') ||
            url.endsWith('.jpeg') ||
            url.endsWith('.png') ||
            url.endsWith('.gif') ||
            url.endsWith('.avif') ||
            url.endsWith('.webp'));

    if (isValidFormat) {
      // Additional check by attempting to load the image
      precacheImage(NetworkImage(url), context).then((_) {
        setState(() {
          _isValidImageUrl = true;
          _isPreviewLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _isValidImageUrl = false;
          _isPreviewLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid image URL or image not accessible')),
        );
      });
    } else {
      setState(() {
        _isValidImageUrl = false;
        _isPreviewLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter a valid image URL (must end with .jpg, .jpeg, .png, .gif, or .webp)')),
      );
    }
  }

  // Save category to Firestore
  Future<void> _saveCategory() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Check if image URL is valid
    if (!_isValidImageUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid image URL and verify it')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare data for Firestore
      final categoryData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add document to Firestore
      await FirebaseFirestore.instance
          .collection('service_categories')
          .add(categoryData);

      // Show success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Category added successfully!')),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Category added successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: Duration(seconds: 3),
        ),
      );

      // Clear form
      _nameController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      setState(() => _isValidImageUrl = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save category: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car Service Category'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Service Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Service Name',
                          border: OutlineInputBorder(),
                          hintText: 'Enter service name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a service name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Image URL Field with Validation Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Image URL',
                                border: OutlineInputBorder(),
                                hintText: 'Enter image URL (https://...)',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an image URL';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _validateImageUrl,
                            child: const Text('Verify'),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Image Preview
                      Container(
                        height: screenHeight * 0.2,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isPreviewLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _isValidImageUrl
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _imageUrlController.text.trim(),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Text('Error loading image'),
                                        );
                                      },
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: screenWidth * 0.1,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      const Text(
                                          'Image preview will appear here'),
                                    ],
                                  ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          hintText: 'Enter service description',
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _saveCategory,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'SAVE CATEGORY',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
