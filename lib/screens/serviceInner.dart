import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_crew/screens/cartProvider.dart';
import 'package:car_crew/screens/cart.dart';

class Serviceinner extends StatefulWidget {
  final String productId;

  const Serviceinner({required this.productId, Key? key}) : super(key: key);
  @override
  State<Serviceinner> createState() => _ServiceinnerState();
}

class _ServiceinnerState extends State<Serviceinner> {
  // Stream for specific product document
  late Stream<DocumentSnapshot> _productStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for the specific product
    _productStream = FirebaseFirestore.instance
        .collection('service_products')
        .doc(widget.productId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _productStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final productData = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                productData['name'] ?? "Service Product",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: deviceWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return Text(
              "Loading...",
              style: TextStyle(
                color: Colors.black,
                fontSize: deviceWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.share, color: Colors.black),
          //   onPressed: () {},
          // ),
          // Add cart icon with badge showing number of items

          Consumer<CartProvider>(
            builder: (_, cart, child) {
              // Assuming `cart.items` is a list of cart items and each item has a `userId` property
              int userItemCount = cart.items
                  .where((item) => item.userId == userId) // Filter by userId
                  .length;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                  ),
                  if (userItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$userItemCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _productStream,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Handle empty data
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Product not found'),
            );
          }

          // Extract data from DocumentSnapshot
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

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        productData['name'] ?? 'Unnamed Product',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 8),

                      // Category
                      Row(
                        children: [
                          Icon(Icons.category, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            productData['categoryName'] ?? 'No Category',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                            Icons.tune, iconDescriptions['recommend'] ?? ''),

                      SizedBox(height: 24),

                      // Included descriptions
                      if (includedDescriptions.isNotEmpty) ...[
                        Text(
                          'What\'s Included',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100], // background color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: includedDescriptions
                                .map((desc) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              desc,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: _productStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return SizedBox(height: 0);
          }

          final productData = snapshot.data!.data() as Map<String, dynamic>;

          // Convert salesPrice to double safely
          double salesPrice = 0.0;
          if (productData['salesPrice'] != null) {
            if (productData['salesPrice'] is int) {
              salesPrice = (productData['salesPrice'] as int).toDouble();
            } else if (productData['salesPrice'] is double) {
              salesPrice = productData['salesPrice'] as double;
            } else if (productData['salesPrice'] is String) {
              salesPrice =
                  double.tryParse(productData['salesPrice'] as String) ?? 0.0;
            }
          }

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹${salesPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String userId =
                        FirebaseAuth.instance.currentUser!.uid; // example

                    // Add to cart functionality
                    cartProvider.addItem(
                      userId: userId,
                      id: widget.productId,
                      name: productData['name'] ?? 'Unknown Service',
                      price: salesPrice,
                      imageUrl: productData['imageUrl'] ?? '',
                    );

                    // Show confirmation message
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to cart!'),
                        duration: Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'VIEW CART',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartPage()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "ADD TO CART",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
}
