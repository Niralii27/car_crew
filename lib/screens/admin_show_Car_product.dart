import 'package:car_crew/screens/admin_add_car_product.dart';
import 'package:car_crew/screens/admin_edit_car_product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCarProductPage extends StatefulWidget {
  const AdminCarProductPage({Key? key}) : super(key: key);

  @override
  State<AdminCarProductPage> createState() => _AdminCarProductPageState();
}

class _AdminCarProductPageState extends State<AdminCarProductPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> carProducts = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCarProducts();
  }

  Future<void> fetchCarProducts() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Query Firestore collection for Toyota cars
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('carProducts')
          .where('categoryId')
          .get();

      final List<Map<String, dynamic>> loadedProducts = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedProducts.add({
          'id': doc.id,
          'categoryId': data['categoryId'] ?? '',
          'categoryName': data['categoryName'] ?? '',
          'title': data['title'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
        });
      }

      setState(() {
        carProducts = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching car products: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteCarProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('carProducts')
          .doc(productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car product deleted successfully')),
      );

      // Refresh the list
      fetchCarProducts();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $error')),
      );
    }
  }

  void navigateToEditPage(Map<String, dynamic> car) async {
    // Navigate to the edit page and await for a result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCarProductPage(car: car),
      ),
    );

    // If the result is true (indicating successful edit), refresh the list
    if (result == true) {
      fetchCarProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cars Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCarProduct()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCarProducts,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : carProducts.isEmpty
                    ? const Center(child: Text('No Toyota cars found'))
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Responsive layout based on screen width
                            if (screenSize.width < 600) {
                              // Mobile layout: List view
                              return ListView.builder(
                                itemCount: carProducts.length,
                                itemBuilder: (context, index) {
                                  final car = carProducts[index];
                                  return AdminCarListItem(
                                    car: car,
                                    onDelete: () => deleteCarProduct(car['id']),
                                    onEdit: () => navigateToEditPage(car),
                                  );
                                },
                              );
                            } else {
                              // Tablet/Desktop layout: Grid view
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      screenSize.width < 900 ? 2 : 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: carProducts.length,
                                itemBuilder: (context, index) {
                                  final car = carProducts[index];
                                  return AdminCarGridItem(
                                    car: car,
                                    onDelete: () => deleteCarProduct(car['id']),
                                    onEdit: () => navigateToEditPage(car),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCarProduct()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AdminCarListItem extends StatelessWidget {
  final Map<String, dynamic> car;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminCarListItem({
    Key? key,
    required this.car,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: SizedBox(
          width: 80,
          height: 80,
          child: car['imageUrl'] != null && car['imageUrl'].isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    car['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.car_rental),
                ),
        ),
        title: Text(
          car['title'] ?? 'Unknown Model',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(car['categoryName'] ?? 'Unknown Category'),
            const SizedBox(height: 4),
            if (car['createdAt'] != null)
              Text(
                'Added: ${_formatTimestamp(car['createdAt'])}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit car',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Car'),
                    content: Text(
                        'Are you sure you want to delete ${car['title']}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Delete car',
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class AdminCarGridItem extends StatelessWidget {
  final Map<String, dynamic> car;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminCarGridItem({
    Key? key,
    required this.car,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image at the top
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: car['imageUrl'] != null && car['imageUrl'].isNotEmpty
                      ? Image.network(
                          car['imageUrl'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error, size: 40),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.car_rental, size: 40),
                          ),
                        ),
                ),
              ),
              // Action buttons overlay
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Edit car',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Car'),
                              content: Text(
                                  'Are you sure you want to delete ${car['title']}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete();
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Delete car',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['title'] ?? 'Unknown Model',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  car['categoryName'] ?? 'Unknown Category',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                if (car['createdAt'] != null)
                  Text(
                    'Added on: ${_formatTimestamp(car['createdAt'])}',
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
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
