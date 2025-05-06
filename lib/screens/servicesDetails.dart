import 'package:car_crew/screens/serviceInner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Servicesdetails extends StatefulWidget {
  final String serviceId;

  const Servicesdetails({required this.serviceId, Key? key}) : super(key: key);
  @override
  State<Servicesdetails> createState() => _ServicesDetailsState();
}

class _ServicesDetailsState extends State<Servicesdetails> {
  // Stream for Firestore data
  late Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for service products related to this service category
    _productsStream = FirebaseFirestore.instance
        .collection('service_products')
        .where('categoryId', isEqualTo: widget.serviceId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Services details",
          style: TextStyle(
            //fontWeight: FontWeight.bold,
            fontSize: deviceWidth * 0.06,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle empty data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No service products found'));
          }

          // Process data and build UI
          final productDocs = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: productDocs.map((doc) {
                  final productData = doc.data() as Map<String, dynamic>;

                  // Create the ServiceProduct object
                  final product = ServiceProduct(
                    id: doc.id,
                    name: productData['name'] ?? 'Unnamed Product',
                    description: productData['description'] ?? 'No description',
                    imageUrl: productData['imageUrl'] ?? '',
                    originalPrice: (productData['originalPrice'] is num)
                        ? (productData['originalPrice'] as num).toDouble()
                        : 0.0,
                    salesPrice: (productData['salesPrice'] is num)
                        ? (productData['salesPrice'] as num).toDouble()
                        : 0.0,
                    categoryName: productData['categoryName'] ?? 'No Category',
                    categoryId: productData['categoryId'] ?? '',
                    iconDescriptions: Map<String, String>.from(
                        productData['iconDescriptions'] ?? {}),
                    includedDescriptions: List<String>.from(
                        productData['includedDescriptions'] ?? []),
                  );

                  return CarServiceCard(product: product);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Service Product Model Class
class ServiceProduct {
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

  ServiceProduct({
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

class CarServiceCard extends StatelessWidget {
  final ServiceProduct product;

  const CarServiceCard({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Extract icon descriptions for display
    String timeInfo = product.iconDescriptions['time'] ?? 'Takes 5 Hours';
    String freqInfo =
        product.iconDescriptions['frequency'] ?? 'Every 10000 Kms / 5 Months';
    String servicesInfo =
        product.iconDescriptions['services'] ?? 'Includes 15 services';

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.03),
      child: Container(
        width: screenWidth * 1.0,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    freqInfo,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    servicesInfo,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    timeInfo,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "₹${product.originalPrice.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "₹${product.salesPrice.toStringAsFixed(0)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/car_service_img1.png",
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.width * 0.2,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            "assets/car_service_img1.png",
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Serviceinner(
                            productId: product.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    ),
                    child: Text("ADD"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
