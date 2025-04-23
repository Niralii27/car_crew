import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditProduct extends StatefulWidget {
  final String productId;
  
  const AdminEditProduct({Key? key, required this.productId}) : super(key: key);

  @override
  State<AdminEditProduct> createState() => _AdminEditProductState();
}

class _AdminEditProductState extends State<AdminEditProduct> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _originalPriceController = TextEditingController();
  final TextEditingController _salesPriceController = TextEditingController();
  final TextEditingController _includedDescriptionController = TextEditingController();

  // Selected category and icon
  String? _selectedCategoryId;
  String _selectedIcon = 'time'; // Default icon

  // List to store descriptions for each icon
  final Map<String, String> _iconDescriptions = {
    'time': '',
    'eye': '',
    'thumb_up': '',
    'recommend': ''
  };

  // List to store included descriptions
  final List<String> _includedDescriptions = [];

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCategoriesLoading = true;

  // Image preview state
  bool _isValidImageUrl = false;
  bool _isPreviewLoading = false;

  // Categories from Firestore
  List<DocumentSnapshot> _categories = [];

  // Key for form validation
  final _formKey = GlobalKey<FormState>();

  // Product data
  Map<String, dynamic>? _productData;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProductData();
  }

  // Load product data from Firestore
  Future<void> _loadProductData() async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('service_products')
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        setState(() {
          _productData = productDoc.data() as Map<String, dynamic>;
          
          // Set text controllers
          _nameController.text = _productData!['name'] ?? '';
          _descriptionController.text = _productData!['description'] ?? '';
          _imageUrlController.text = _productData!['imageUrl'] ?? '';
          _originalPriceController.text = (_productData!['originalPrice'] ?? 0.0).toString();
          _salesPriceController.text = (_productData!['salesPrice'] ?? 0.0).toString();
          
          // Set category
          _selectedCategoryId = _productData!['categoryId'];
          
          // Set icon descriptions
          if (_productData!['iconDescriptions'] != null) {
            final iconDescs = _productData!['iconDescriptions'] as Map<String, dynamic>;
            iconDescs.forEach((key, value) {
              if (_iconDescriptions.containsKey(key)) {
                _iconDescriptions[key] = value.toString();
              }
            });
          }
          
          // Set included descriptions
          if (_productData!['includedDescriptions'] != null) {
            final includedDescs = _productData!['includedDescriptions'] as List<dynamic>;
            _includedDescriptions.clear();
            _includedDescriptions.addAll(includedDescs.map((desc) => desc.toString()));
          }
          
          // Validate image URL
          if (_imageUrlController.text.isNotEmpty) {
            _isValidImageUrl = true;
          }
          
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  // Load categories from Firestore
  Future<void> _loadCategories() async {
    try {
      final categoriesSnapshot = await FirebaseFirestore.instance
          .collection('service_categories')
          .orderBy('name')
          .get();

      setState(() {
        _categories = categoriesSnapshot.docs;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
      setState(() => _isCategoriesLoading = false);
    }
  }

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

  // Add description to included descriptions list
  void _addIncludedDescription() {
    final description = _includedDescriptionController.text.trim();
    if (description.isNotEmpty) {
      setState(() {
        _includedDescriptions.add(description);
        _includedDescriptionController.clear();
      });
    }
  }

  // Remove description from included descriptions list
  void _removeIncludedDescription(int index) {
    setState(() {
      _includedDescriptions.removeAt(index);
    });
  }

  // Update product in Firestore
  Future<void> _updateProduct() async {
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

    // Check if category is selected
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Get selected category data
      final selectedCategory = _categories.firstWhere(
        (category) => category.id == _selectedCategoryId,
      );

      // Prepare data for Firestore
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'originalPrice': double.parse(_originalPriceController.text.trim()),
        'salesPrice': double.parse(_salesPriceController.text.trim()),
        'categoryId': _selectedCategoryId,
        'categoryName': selectedCategory['name'],
        'categoryImage': selectedCategory['imageUrl'],
        'iconDescriptions': _iconDescriptions,
        'includedDescriptions': _includedDescriptions,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update document in Firestore
      await FirebaseFirestore.instance
          .collection('service_products')
          .doc(widget.productId)
          .update(productData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Product updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: Duration(seconds: 3),
        ),
      );

      // Go back to previous screen
      Navigator.pop(context, true);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Get icon widget based on icon name
  Widget _getIconWidget(String iconName) {
    switch (iconName) {
      case 'time':
        return const Icon(Icons.access_time);
      case 'eye':
        return const Icon(Icons.visibility);
      case 'thumb_up':
        return const Icon(Icons.thumb_up);
      case 'recommend':
        return const Icon(Icons.recommend);
      default:
        return const Icon(Icons.access_time);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _originalPriceController.dispose();
    _salesPriceController.dispose();
    _includedDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Car Service Product'),
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
                      // Category Dropdown
                      _isCategoriesLoading
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Select Category',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Select a category'),
                              value: _selectedCategoryId,
                              items: _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category['name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                            ),

                      SizedBox(height: screenHeight * 0.02),

                      // Product Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                          hintText: 'Enter product name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a product name';
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
                          hintText: 'Enter product description',
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Price Fields
                      Row(
                        children: [
                          // Original Price Field
                          Expanded(
                            child: TextFormField(
                              controller: _originalPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Original Price',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          // Sales Price Field
                          Expanded(
                            child: TextFormField(
                              controller: _salesPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Sales Price',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Icon Descriptions Section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Icon Descriptions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Time Icon Description
                              _buildIconDescriptionField(
                                'time',
                                'Time Description',
                                'Enter time-related description',
                              ),
                              const SizedBox(height: 10),

                              // Eye Icon Description
                              _buildIconDescriptionField(
                                'eye',
                                'Eye Description',
                                'Enter visibility-related description',
                              ),
                              const SizedBox(height: 10),

                              // Thumb Up Icon Description
                              _buildIconDescriptionField(
                                'thumb_up',
                                'Thumb Up Description',
                                'Enter recommendation description',
                              ),
                              const SizedBox(height: 10),

                              // Recommended Icon Description
                              _buildIconDescriptionField(
                                'recommend',
                                'Recommended Description',
                                'Enter why this is recommended',
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Included Descriptions Section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Included Descriptions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Add new included description
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          _includedDescriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'New Description',
                                        border: OutlineInputBorder(),
                                        hintText:
                                            'Enter a new included description',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: _addIncludedDescription,
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // List of included descriptions
                              ..._includedDescriptions
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final description = entry.value;

                                return Card(
                                  color: Colors.grey[100],
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(description),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeIncludedDescription(index),
                                    ),
                                  ),
                                );
                              }).toList(),

                              if (_includedDescriptions.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'No descriptions added yet',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Update Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _updateProduct,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'UPDATE PRODUCT',
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

  // Helper method to build icon description fields
  Widget _buildIconDescriptionField(
      String iconName, String label, String hint) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: _getIconWidget(iconName),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            initialValue: _iconDescriptions[iconName],
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              hintText: hint,
            ),
            onChanged: (value) {
              _iconDescriptions[iconName] = value;
            },
          ),
        ),
      ],
    );
  }
}