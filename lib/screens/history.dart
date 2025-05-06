import 'package:car_crew/screens/review.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistroyPage extends StatefulWidget {
  const HistroyPage({Key? key}) : super(key: key);

  @override
  State<HistroyPage> createState() => _HistroyPageState();
}

class _HistroyPageState extends State<HistroyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to continuously listen for booking changes
  Stream<QuerySnapshot>? _bookingsStream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookingHistory();
  }

  void _fetchBookingHistory() {
    // Get the current logged-in user
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        setState(() {
          // Create a stream that listens to the Booking collection
          // filtered by the current user's ID and ordered by createdAt timestamp
          _bookingsStream = _firestore
              .collection('Booking')
              .where('userId', isEqualTo: user.uid)
              .snapshots(); // Removed the orderBy to avoid index requirement
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bookings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Handle the case where the user is not logged in
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Format Timestamp to readable date
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  // Format date-only from Timestamp
  String _formatDateOnly(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletOrDesktop = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _auth.currentUser == null
              ? const Center(
                  child: Text(
                    'Please log in to view your booking history',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: _bookingsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No booking history found',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    // Display booking history
                    // Sort documents manually since we removed orderBy
                    final sortedDocs = snapshot.data!.docs.toList()
                      ..sort((a, b) {
                        var aData = a.data() as Map<String, dynamic>;
                        var bData = b.data() as Map<String, dynamic>;

                        // Fallback to comparing document IDs if createdAt is missing
                        if (aData['createdAt'] == null ||
                            bData['createdAt'] == null) {
                          return a.id.compareTo(b.id);
                        }

                        // Sort by createdAt in descending order
                        return (bData['createdAt'] as Timestamp)
                            .compareTo(aData['createdAt'] as Timestamp);
                      });

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          // Error message about missing index with clickable link

                          Expanded(
                            child: ListView.builder(
                              itemCount: sortedDocs.length,
                              itemBuilder: (context, index) {
                                // Get booking data
                                var bookingData = sortedDocs[index].data()
                                    as Map<String, dynamic>;

                                // Get services from booking
                                List<dynamic> services =
                                    bookingData['services'] ?? [];

                                // Get payment details
                                Map<String, dynamic> paymentDetails =
                                    bookingData['paymentDetails'] ?? {};

                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header row with booking ID and date
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Booking ID: ${bookingData['bookingId'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    bookingData['status']),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                bookingData['status'] ??
                                                    'Pending',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Divider(height: 24),

                                        // Customer information
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Customer Details',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Name: ${bookingData['customerName'] ?? 'N/A'}',
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Phone: ${bookingData['phoneNumber'] ?? 'N/A'}',
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Vehicle: ${bookingData['vehicleModel'] ?? 'N/A'}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isTabletOrDesktop)
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Appointment',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'Date: ${bookingData['bookingDate'] != null ? _formatDateOnly(bookingData['bookingDate']) : 'N/A'}',
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Time: ${bookingData['timeSlot'] ?? 'N/A'}',
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Address: ${bookingData['address'] ?? 'N/A'}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),

                                        if (!isTabletOrDesktop) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Appointment',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Date: ${bookingData['bookingDate'] != null ? _formatDateOnly(bookingData['bookingDate']) : 'N/A'}',
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Time: ${bookingData['timeSlot'] ?? 'N/A'}',
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Address: ${bookingData['address'] ?? 'N/A'}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ],

                                        const SizedBox(height: 16),

                                        // Services
                                        const Text(
                                          'Services',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Service list
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: services.length,
                                          itemBuilder: (context, serviceIndex) {
                                            Map<String, dynamic> service =
                                                services[serviceIndex];
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  service['imageUrl'] ?? '',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: Colors.grey[300],
                                                      child: const Icon(Icons
                                                          .image_not_supported),
                                                    );
                                                  },
                                                ),
                                              ),
                                              title: Text(
                                                  service['serviceName'] ??
                                                      'N/A'),
                                              trailing: Text(
                                                '₹${service['price']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        const Divider(height: 24),

                                        // Payment details
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Payment Details',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getPaymentStatusColor(
                                                    bookingData[
                                                        'paymentStatus']),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                bookingData['paymentStatus'] ??
                                                    'Pending',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'Method: ${bookingData['paymentMethod'] ?? 'N/A'}'),
                                            Text(
                                              'Total: ₹${bookingData['totalAmount'] ?? 0}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (paymentDetails['paymentId'] !=
                                            null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Payment ID: ${paymentDetails['paymentId']}',
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ],

                                        const SizedBox(height: 12),
                                        Text(
                                          'Created: ${bookingData['createdAt'] != null ? _formatTimestamp(bookingData['createdAt']) : 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Navigate to review page with required data
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReviewPage(
                                                      bookingData: bookingData,
                                                      services: services,
                                                      userId: _auth
                                                          .currentUser!.uid,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text('Add review'),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  // Helper function to get color based on booking status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper function to get color based on payment status
  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
