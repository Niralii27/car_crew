import 'package:car_crew/screens/admin_add_car_Category.dart';
import 'package:car_crew/screens/admin_add_car_product.dart';
import 'package:car_crew/screens/admin_show_Car_product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminShowVehicle extends StatefulWidget {
  const AdminShowVehicle({super.key});

  @override
  State<AdminShowVehicle> createState() => _AdminShowVehicleState();
}

class _AdminShowVehicleState extends State<AdminShowVehicle> {
  String selectedFilter = "All Categories";
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final List<String> filterOptions = [
    "All Categories",
    // "Popular",
    "Recently Added",
    "Alphabetical"
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetch vehicle categories from Firestore
  Stream<QuerySnapshot> getVehicleCategories() {
    final categoriesRef =
        FirebaseFirestore.instance.collection('carCategories');

    switch (selectedFilter) {
      // case "Popular":
      //   return categoriesRef.orderBy('viewCount', descending: true).snapshots();
      case "Recently Added":
        return categoriesRef.orderBy('createdAt', descending: true).snapshots();
      case "Alphabetical":
        return categoriesRef.orderBy('title').snapshots();
      default:
        return categoriesRef.snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = (width / 150).floor().clamp(2, 5);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: const Text("Vehicle Categories",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: Colors.black),
            onSelected: (String value) {
              if (value == 'Add Category') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCarCategory()),
                ).then((value) {
                  if (value == true) {
                    setState(() {});
                  }
                });
              } else if (value == 'Add Product') {
                // Navigate to AddProduct page (create this page if not already)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCarProduct()),
                );
              } else if (value == 'Show Product') {
                // Navigate to ShowProduct page (create this page if not already)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminCarProductPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Add Category',
                child: Text('Add Category'),
              ),
              const PopupMenuItem<String>(
                value: 'Add Product',
                child: Text('Add Product'),
              ),
              const PopupMenuItem<String>(
                value: 'Show Product',
                child: Text('Show Product'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter dropdown and search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search vehicle category',
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      icon: Icon(Icons.filter_list, color: Colors.blue),
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w500),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFilter = newValue!;
                        });
                      },
                      items: filterOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getVehicleCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading categories",
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined,
                            size: 70, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No categories available",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Add your first category with the '+' button",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final categories = snapshot.data!.docs;

                // Filter categories based on search query
                final filteredCategories = searchQuery.isEmpty
                    ? categories
                    : categories.where((doc) {
                        final title = doc['title'].toString().toLowerCase();
                        return title.contains(searchQuery.toLowerCase());
                      }).toList();

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Text(
                      "No categories match your search",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final timestamp = category['createdAt'] as Timestamp?;
                    final dateString = timestamp != null
                        ? DateFormat('MMM d, yyyy').format(timestamp.toDate())
                        : 'N/A';

                    return GestureDetector(
                      onTap: () async {
                        // Increment view count when a category is tapped
                        await FirebaseFirestore.instance
                            .collection('carCategories')
                            .doc(category.id)
                            .update({
                          'viewCount': FieldValue.increment(1),
                        });

                        // Navigate or perform action
                        print("Selected category: ${category['title']}");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                category['imageUrl'],
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image,
                                        size: 50, color: Colors.grey[400]),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Added on $dateString",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
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
