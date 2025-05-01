import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCarCategory extends StatefulWidget {
  const AddCarCategory({super.key});

  @override
  State<AddCarCategory> createState() => _AddCarCategoryState();
}

class _AddCarCategoryState extends State<AddCarCategory> {
  final TextEditingController categoryTitleController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    categoryTitleController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  // Preview the image from URL
  bool isValidImageUrl = false;
  bool isCheckingUrl = false;

  void checkImageUrl(String url) {
    if (url.isEmpty) {
      setState(() {
        isValidImageUrl = false;
        isCheckingUrl = false;
      });
      return;
    }

    setState(() {
      isCheckingUrl = true;
    });

    // Create an image widget to check if URL loads correctly
    Image image = Image.network(url);
    final listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        // Image loaded successfully
        setState(() {
          isValidImageUrl = true;
          isCheckingUrl = false;
        });
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        // Error loading image
        setState(() {
          isValidImageUrl = false;
          isCheckingUrl = false;
        });
      },
    );

    image.image.resolve(ImageConfiguration()).addListener(listener);
  }

  Future<void> addCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final imageUrl = imageUrlController.text.trim();
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid image URL')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Add category to Firestore using the provided image URL
      await FirebaseFirestore.instance.collection('carCategories').add({
        'title': categoryTitleController.text.trim(),
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'viewCount': 0
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added successfully!')));

      // Return to previous screen with refresh flag
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding category: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: const Text("Add Car Category",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Image URL Field
                Text(
                  "Image URL",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    hintText: "Enter image URL",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.link, color: Colors.blue),
                    suffixIcon: isCheckingUrl
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : isValidImageUrl && imageUrlController.text.isNotEmpty
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : imageUrlController.text.isNotEmpty
                                ? Icon(Icons.error, color: Colors.red)
                                : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an image URL';
                    }
                    // Basic URL validation
                    bool validURL =
                        Uri.tryParse(value)?.hasAbsolutePath ?? false;
                    if (!validURL) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Validate URL when typing stops
                    if (value.isNotEmpty) {
                      checkImageUrl(value);
                    }
                  },
                ),

                SizedBox(height: 20),

                // Image Preview
                if (imageUrlController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isValidImageUrl
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: isCheckingUrl
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : isValidImageUrl
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              size: 40, color: Colors.red),
                                          SizedBox(height: 8),
                                          Text("Failed to load image",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 40, color: Colors.red),
                                    SizedBox(height: 8),
                                    Text(
                                      "Invalid image URL",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  )
                else
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Image Preview",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Enter a URL above to preview",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 30),

                // Category Title Field
                Text(
                  "Category Title",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: categoryTitleController,
                  decoration: InputDecoration(
                    hintText: "Enter category title",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.category, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category title';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 40),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
