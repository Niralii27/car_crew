import 'package:car_crew/screens/add_admin_services.dart';
import 'package:car_crew/screens/admin_edit_product.dart';
import 'package:car_crew/screens/admin_edit_sos_product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSOSProduct extends StatefulWidget {
  @override
  State<AdminSOSProduct> createState() => _AdminSOSProductState();
}

class _AdminSOSProductState extends State<AdminSOSProduct> {
  // Stream for Firestore data
  late Stream<QuerySnapshot> _productsStream;

  // Selected product ID for details view
  String? _selectedProductId;

  // Track if details are being shown
  bool _showingDetails = false;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for service products
    _productsStream = FirebaseFirestore.instance
        .collection('sos_products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("SOS Service Products", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_showingDetails) {
              // If showing details, go back to the list
              setState(() {
                _showingDetails = false;
                _selectedProductId = null;
              });
            } else {
              // Otherwise, go back to previous screen
              Navigator.pop(context);
            }
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showingDetails && _selectedProductId != null
            ? _buildProductDetails(_selectedProductId!)
            : Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminAddProduct()),
                      );
                    },
                    child: Text("ADD NEW PRODUCT"),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _productsStream,
                      builder: (context, snapshot) {
                        // Handle loading state
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        // Handle error state
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        // Handle empty data
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text('No products found'),
                          );
                        }

                        // Process and display the data
                        final products = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            // Extract data from DocumentSnapshot
                            final productData =
                                products[index].data() as Map<String, dynamic>;
                            final productId = products[index].id;

                            // Convert to Product object
                            final product = Product(
                              id: productId,
                              name: productData['name'] ?? 'Unnamed Product',
                              description: productData['description'] ??
                                  'No description',
                              imageUrl: productData['imageUrl'] ?? '',
                              originalPrice:
                                  (productData['originalPrice'] is num)
                                      ? (productData['originalPrice'] as num)
                                          .toDouble()
                                      : 0.0,
                              salesPrice: (productData['salesPrice'] is num)
                                  ? (productData['salesPrice'] as num)
                                      .toDouble()
                                  : 0.0,
                              categoryName:
                                  productData['categoryName'] ?? 'No Category',
                              categoryId: productData['categoryId'] ?? '',
                              iconDescriptions: Map<String, String>.from(
                                  productData['iconDescriptions'] ?? {}),
                              includedDescriptions: List<String>.from(
                                  productData['includedDescriptions'] ?? []),
                            );

                            return ProductCard(
                              product: product,
                              onTap: () => _selectProduct(productId),
                              onShowPressed: () =>
                                  _showProductDetails(productId),
                              onEditPressed: () => _editProduct(product),
                              onDeletePressed: () => _deleteProduct(productId),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Method to select a product (for highlighting)
  void _selectProduct(String productId) {
    setState(() {
      _selectedProductId = productId;
    });
  }

  // Method to show product details
  void _showProductDetails(String productId) {
    setState(() {
      _selectedProductId = productId;
      _showingDetails = true;
    });
  }

  // Build product details widget
  Widget _buildProductDetails(String productId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sos_products')
          .doc(productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Product not found'));
        }

        final productData = snapshot.data!.data() as Map<String, dynamic>;

        // Parse icon descriptions
        final iconDescriptions =
            Map<String, String>.from(productData['iconDescriptions'] ?? {});

        // Parse included descriptions
        final includedDescriptions =
            List<String>.from(productData['includedDescriptions'] ?? []);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    productData['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 50),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Product name
              Text(
                productData['name'] ?? 'Unnamed Product',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              // Category
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    productData['categoryName'] ?? 'No Category',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Price information
              Row(
                children: [
                  Text(
                    '₹${productData['salesPrice']?.toString() ?? '0.0'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(width: 8),
                  if ((productData['originalPrice'] ?? 0.0) >
                      (productData['salesPrice'] ?? 0.0))
                    Text(
                      '₹${productData['originalPrice']?.toString() ?? '0.0'}',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16),

              // Description
              Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                productData['description'] ?? 'No description',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 24),

              // Icon descriptions
              Text(
                'Features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Time icon
              if (iconDescriptions['time']?.isNotEmpty ?? false)
                _buildIconDescriptionTile(
                    Icons.access_time, iconDescriptions['time'] ?? ''),

              // Eye icon
              if (iconDescriptions['eye']?.isNotEmpty ?? false)
                _buildIconDescriptionTile(
                    Icons.visibility, iconDescriptions['eye'] ?? ''),

              // Thumb up icon
              if (iconDescriptions['thumb_up']?.isNotEmpty ?? false)
                _buildIconDescriptionTile(
                    Icons.thumb_up, iconDescriptions['thumb_up'] ?? ''),

              // Recommended icon
              if (iconDescriptions['recommend']?.isNotEmpty ?? false)
                _buildIconDescriptionTile(
                    Icons.recommend, iconDescriptions['recommend'] ?? ''),

              SizedBox(height: 24),

              // Included descriptions
              if (includedDescriptions.isNotEmpty) ...[
                Text(
                  'What\'s Included',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...includedDescriptions
                    .map((desc) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(desc,
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                        ))
                    .toList(),
              ],

              SizedBox(height: 24),

              // Edit and Delete buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('EDIT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _editProduct(Product(
                        id: productId,
                        name: productData['name'] ?? '',
                        description: productData['description'] ?? '',
                        imageUrl: productData['imageUrl'] ?? '',
                        originalPrice: (productData['originalPrice'] is num)
                            ? (productData['originalPrice'] as num).toDouble()
                            : 0.0,
                        salesPrice: (productData['salesPrice'] is num)
                            ? (productData['salesPrice'] as num).toDouble()
                            : 0.0,
                        categoryName: productData['categoryName'] ?? '',
                        categoryId: productData['categoryId'] ?? '',
                        iconDescriptions: iconDescriptions,
                        includedDescriptions: includedDescriptions,
                      )),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('DELETE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _deleteProduct(productId).then((_) {
                          setState(() {
                            _showingDetails = false;
                            _selectedProductId = null;
                          });
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build icon description tile
  Widget _buildIconDescriptionTile(IconData icon, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue[700]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                description,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to navigate to edit screen
  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEditSOSProduct(productId: product.id),
      ),
    ).then((result) {
      // If product was updated successfully, refresh your product display
      if (result == true) {
        // Option 1: If you're using StatefulWidget, trigger a rebuild
        setState(() {
          // This will cause the build method to run again
        });
      }
    });
  }

  // Method to delete a product
  Future<void> _deleteProduct(String productId) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Product'),
            content: Text('Are you sure you want to delete this sos product?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('DELETE', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      await FirebaseFirestore.instance
          .collection('sos_products')
          .doc(productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete SOS product: $e')),
      );
    }
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double originalPrice;
  final double salesPrice;
  final String categoryName;
  final String categoryId;
  final Map<String, String> iconDescriptions;
  final List<String> includedDescriptions;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.originalPrice,
    required this.salesPrice,
    required this.categoryName,
    required this.categoryId,
    required this.iconDescriptions,
    required this.includedDescriptions,
  });
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onShowPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onShowPressed,
    this.onEditPressed,
    this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap, // Make the card clickable
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrl.startsWith('http')
                        ? Image.network(
                            product.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          )
                        : Image.asset(
                            product.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(width: 10),
                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '₹${product.salesPrice}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            if (product.originalPrice > product.salesPrice)
                              Text(
                                '₹${product.originalPrice}',
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Category: ${product.categoryName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Show button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('SHOW'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: onShowPressed,
                    ),
                  ),
                  SizedBox(width: 8),
                  // Edit button
                  if (onEditPressed != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEditPressed,
                      tooltip: 'Edit',
                      constraints: BoxConstraints(minWidth: 40),
                      padding: EdgeInsets.zero,
                    ),
                  // Delete button
                  if (onDeletePressed != null)
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: onDeletePressed,
                      tooltip: 'Delete',
                      constraints: BoxConstraints(minWidth: 40),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
