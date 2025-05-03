import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Selectvehicle extends StatefulWidget {
  const Selectvehicle({super.key});

  @override
  State<Selectvehicle> createState() => _SelectvehicleState();
}

class _SelectvehicleState extends State<Selectvehicle> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = (width / 100).floor().clamp(2, 5);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: const Text("Select Your Vehicle",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Vehicle Model or Brand',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carCategories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No car categories found"));
                }

                final categories = snapshot.data!.docs;

                // Filter categories based on search query
                final filteredCategories = _searchQuery.isEmpty
                    ? categories
                    : categories.where((doc) {
                        final title = doc['title'].toString().toLowerCase();
                        return title.contains(_searchQuery);
                      }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final name = category['title'] as String;
                    final logo = category['imageUrl'] as String;
                    final categoryId = category.id;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarProductsPage(
                              categoryId: categoryId,
                              categoryName: name,
                            ),
                          ),
                        ).then((result) {
                          // If we got a result from the products page, pass it back
                          if (result != null) {
                            Navigator.pop(context, result);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: logo.startsWith('http')
                                  ? Image.network(
                                      logo,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: 50, color: Colors.red);
                                      },
                                    )
                                  : Image.asset(
                                      logo,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: 50, color: Colors.red);
                                      },
                                    ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CarProductsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CarProductsPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CarProductsPage> createState() => _CarProductsPageState();
}

class _CarProductsPageState extends State<CarProductsPage> {
  String? _selectedProductId;
  Map<String, dynamic>? _selectedProduct;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          "${widget.categoryName} Products",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carProducts')
                  .where('categoryId', isEqualTo: widget.categoryId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text("No products found for this category"));
                }

                final products = snapshot.data!.docs;

                // Filter products based on search query
                final filteredProducts = _searchQuery.isEmpty
                    ? products
                    : products.where((doc) {
                        final title = doc['title'].toString().toLowerCase();
                        final categoryName =
                            doc['categoryName']?.toString().toLowerCase() ?? '';
                        return title.contains(_searchQuery) ||
                            categoryName.contains(_searchQuery);
                      }).toList();

                final width = MediaQuery.of(context).size.width;
                final crossAxisCount = (width / 120).floor().clamp(2, 5);

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75, // Adjust for taller cards
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final productId = product.id;
                    final name = product['title'] as String;
                    final categoryName =
                        product['categoryName'] as String? ?? widget.categoryName;
                    final imageUrl = product['imageUrl'] as String? ?? '';

                    final isSelected = _selectedProductId == productId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Toggle selection - if already selected, deselect, otherwise select this one
                          if (isSelected) {
                            _selectedProductId = null;
                            _selectedProduct = null;
                          } else {
                            _selectedProductId = productId;
                            _selectedProduct = {
                              'productId': productId,
                              'productName': name,
                              'categoryName': categoryName,
                              'categoryId': widget.categoryId,
                              'imageUrl': imageUrl
                            };
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.white,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.directions_car,
                                              size: 50, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : Icon(Icons.directions_car,
                                      size: 60, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (categoryName.isNotEmpty)
                              Text(
                                categoryName,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedProductId != null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () {
                  // Return the selected product data to the car detail page
                  Navigator.pop(context, _selectedProduct);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Select This Vehicle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }
}