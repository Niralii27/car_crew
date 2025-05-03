import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCarProductPage extends StatefulWidget {
  final Map<String, dynamic> car;

  const EditCarProductPage({
    Key? key,
    required this.car,
  }) : super(key: key);

  @override
  State<EditCarProductPage> createState() => _EditCarProductPageState();
}

class _EditCarProductPageState extends State<EditCarProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _imageUrlController;

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isLoading = false;

  // For image validation
  bool _isValidImageUrl = false;
  bool _isCheckingUrl = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.car['title'] ?? '');
    _imageUrlController =
        TextEditingController(text: widget.car['imageUrl'] ?? '');
    _selectedCategoryId = widget.car['categoryId'];
    _selectedCategoryName = widget.car['categoryName'];

    // Validate initial image URL
    if (_imageUrlController.text.isNotEmpty) {
      checkImageUrl(_imageUrlController.text);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Check if image URL is valid
  void checkImageUrl(String url) {
    if (url.isEmpty) {
      setState(() {
        _isValidImageUrl = false;
        _isCheckingUrl = false;
      });
      return;
    }

    setState(() {
      _isCheckingUrl = true;
    });

    // Create an image widget to check if URL loads correctly
    Image image = Image.network(url);
    final listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        // Image loaded successfully
        setState(() {
          _isValidImageUrl = true;
          _isCheckingUrl = false;
        });
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        // Error loading image
        setState(() {
          _isValidImageUrl = false;
          _isCheckingUrl = false;
        });
      },
    );

    image.image.resolve(ImageConfiguration()).addListener(listener);
  }

  Future<void> _saveCarProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a category')));
      return;
    }

    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty || !_isValidImageUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid image URL')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update the car product in Firestore
      await FirebaseFirestore.instance
          .collection('carProducts')
          .doc(widget.car['id'])
          .update({
        'title': _titleController.text.trim(),
        'imageUrl': imageUrl,
        'categoryId': _selectedCategoryId,
        'categoryName': _selectedCategoryName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car product updated successfully')));

      // Return to previous screen with refresh flag
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating product: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    // Responsive padding based on screen size
    final horizontalPadding = width < 600 ? 16.0 : 24.0;
    final verticalPadding = height < 700 ? 16.0 : 24.0;

    // Responsive spacing
    final spacing = width < 600 ? 16.0 : 24.0;

    // Responsive font and icon sizes
    final titleFontSize = width < 600 ? 18.0 : 22.0;
    final labelFontSize = width < 600 ? 14.0 : 16.0;
    final iconSize = width < 600 ? 22.0 : 26.0;

    // Responsive button height
    final buttonHeight = width < 600 ? 50.0 : 55.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          "Edit Car Product",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Selection
                Text(
                  "Category",
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: spacing / 2),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('carCategories')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'Error loading categories',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final categories = snapshot.data?.docs ?? [];

                    if (categories.isEmpty) {
                      return Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'No categories available',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          hint: Text('Select a category'),
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                          value: _selectedCategoryId,
                          items: categories.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      doc['imageUrl'],
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 30,
                                          height: 30,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.broken_image,
                                              size: 15),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      doc['title'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategoryId = value;
                                // Get the category name for the selected ID
                                final selectedDoc = categories.firstWhere(
                                  (doc) => doc.id == value,
                                );
                                _selectedCategoryName = selectedDoc['title'];
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: spacing),

                // Product Title Field
                Text(
                  "Product Title",
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: spacing / 2),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Enter product title",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.directions_car,
                        color: Colors.blue, size: iconSize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a product title';
                    }
                    return null;
                  },
                ),

                SizedBox(height: spacing),

                // Image URL Field
                Text(
                  "Image URL",
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: spacing / 2),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: "Enter image URL",
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon:
                        Icon(Icons.link, color: Colors.blue, size: iconSize),
                    suffixIcon: _isCheckingUrl
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : _isValidImageUrl &&
                                _imageUrlController.text.isNotEmpty
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : _imageUrlController.text.isNotEmpty
                                ? Icon(Icons.error, color: Colors.red)
                                : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
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

                SizedBox(height: spacing),

                // Image Preview
                if (_imageUrlController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: width < 600 ? 180 : 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isValidImageUrl
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: _isCheckingUrl
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : _isValidImageUrl
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
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
                  Container(
                    width: double.infinity,
                    height: width < 600 ? 180 : 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image,
                            size: iconSize * 2, color: Colors.grey),
                        SizedBox(height: spacing / 2),
                        Text(
                          "Image Preview",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: labelFontSize,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Enter an image URL to preview",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: labelFontSize - 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: spacing * 1.5),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCarProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Update Product',
                            style: TextStyle(
                              fontSize: labelFontSize + 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
