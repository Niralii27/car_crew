import 'package:car_crew/screens/admin_add_category.dart';
import 'package:car_crew/screens/editcategory.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminServices extends StatefulWidget {
  @override
  State<AdminServices> createState() => _AdminServicesState();
}

class _AdminServicesState extends State<AdminServices> {
  // Stream for Firestore data
  late Stream<QuerySnapshot> _categoriesStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for service categories
    _categoriesStream = FirebaseFirestore.instance
        .collection('service_categories')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Periodic Services", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminAddCategory()),
                );
              },
              child: Text("ADD SERVICES"),
            ),
            SizedBox(height: 16),
            Expanded(
              // Stream builder to listen to Firestore updates
              child: StreamBuilder<QuerySnapshot>(
                stream: _categoriesStream,
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
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No service categories found'),
                    );
                  }

                  // Process and display the data
                  final categories = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      // Extract data from DocumentSnapshot
                      final categoryData =
                          categories[index].data() as Map<String, dynamic>;

                      // Convert to Service object
                      final service = Service(
                        id: categories[index].id,
                        title: categoryData['name'] ?? 'Unnamed Service',
                        description:
                            categoryData['description'] ?? 'No description',
                        imageUrl: categoryData['imageUrl'] ?? '',
                      );

                      return ServiceCard(
                        service: service,
                        onEditPressed: () => _editCategory(service),
                        onDeletePressed: () => _deleteCategory(service.id),
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

  // Method to navigate to edit screen
  void _editCategory(Service service) {
    // Replace with your actual edit screen implementation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(serviceId: service.id),
      ),
    );
  }

  // Method to delete a category
  Future<void> _deleteCategory(String categoryId) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Category'),
            content: Text('Are you sure you want to delete this category?'),
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
          .collection('service_categories')
          .doc(categoryId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category: $e')),
      );
    }
  }
}

// Edit Category Screen (placeholder - implement as needed)
// class EditCategoryScreen extends StatelessWidget {
//   final String serviceId;

//   const EditCategoryScreen({Key? key, required this.serviceId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Edit Category')),
//       body: Center(
//         child: Text('Edit category with ID: $serviceId'),
//       ),
//     );
//   }
// }

class Service {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const ServiceCard({
    Key? key,
    required this.service,
    this.onEditPressed,
    this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(service.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  SizedBox(height: 8),
                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: service.imageUrl.startsWith('http')
                  ? Image.network(
                      service.imageUrl,
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
                      service.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
