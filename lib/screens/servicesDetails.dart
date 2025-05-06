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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for service products related to this service category
    _productsStream = FirebaseFirestore.instance
        .collection('service_products')
        .where('categoryId', isEqualTo: widget.serviceId)
        .snapshots();

    // Debug print to verify the service ID
    print('Loading services for category ID: ${widget.serviceId}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Services Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: deviceWidth * 0.055,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blue.shade700,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),

          // Main Content - Service Product List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _productsStream,
              builder: (context, snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Handle error state
                if (snapshot.hasError) {
                  print('Error fetching data: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                // Handle empty data
                if (!snapshot.hasData) {
                  print('No data returned from snapshot');
                  return const Center(child: Text('No service products found'));
                }

                final docs = snapshot.data!.docs;
                print('Retrieved ${docs.length} documents from Firestore');

                if (docs.isEmpty) {
                  print('No documents found for category: ${widget.serviceId}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.car_repair,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'No service products found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                // Filter products based on search query
                final filteredDocs = _searchQuery.isEmpty
                    ? docs
                    : docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] ?? '').toString().toLowerCase();
                        final description = (data['description'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(_searchQuery) ||
                            description.contains(_searchQuery);
                      }).toList();

                print(
                    'Filtered to ${filteredDocs.length} documents after search');

                // Display filtered results
                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No results found for "$_searchQuery"',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Debug print
                    print(
                        'Rendering product: ${data['name']}, ID: ${doc.id}, CategoryID: ${data['categoryId']}');

                    // Create the ServiceProduct object
                    final product = ServiceProduct(
                      id: doc.id,
                      name: data['name'] ?? 'Unnamed Product',
                      description: data['description'] ?? 'No description',
                      imageUrl: data['imageUrl'] ?? '',
                      originalPrice: (data['originalPrice'] is num)
                          ? (data['originalPrice'] as num).toDouble()
                          : 0.0,
                      salesPrice: (data['salesPrice'] is num)
                          ? (data['salesPrice'] as num).toDouble()
                          : 0.0,
                      categoryName: data['categoryName'] ?? 'No Category',
                      categoryId: data['categoryId'] ?? '',
                      iconDescriptions: Map<String, String>.from(
                          data['iconDescriptions'] ?? {}),
                      includedDescriptions:
                          List<String>.from(data['includedDescriptions'] ?? []),
                    );

                    return CarServiceCard(product: product);
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

    // Extract icon descriptions for display
    String timeInfo = product.iconDescriptions['time'] ?? 'Takes 5 Hours';
    String freqInfo =
        product.iconDescriptions['eye'] ?? 'Every 10000 Kms / 5 Months';
    String servicesInfo =
        product.iconDescriptions['thumb_up'] ?? 'Includes 15 services';

    // Calculate discount percentage
    int discountPercentage = 0;
    if (product.originalPrice > 0) {
      discountPercentage = ((product.originalPrice - product.salesPrice) /
              product.originalPrice *
              100)
          .round();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Serviceinner(
                    productId: product.id,
                  ),
                ),
              );
            },
            splashColor: Colors.blue.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                timeInfo,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.visibility,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                freqInfo,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.build,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                servicesInfo,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              "₹${product.originalPrice.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "₹${product.salesPrice.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            if (discountPercentage > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "$discountPercentage% OFF",
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.width * 0.25,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      color: Colors.blue.shade50,
                                      child: Icon(
                                        Icons.car_repair,
                                        size: 40,
                                        color: Colors.blue.shade300,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.width * 0.25,
                                  color: Colors.blue.shade50,
                                  child: Icon(
                                    Icons.car_repair,
                                    size: 40,
                                    color: Colors.blue.shade300,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
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
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "VIEW DETAILS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
