import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final List<dynamic> services;
  final String userId;

  const ReviewPage({
    Key? key,
    required this.bookingData,
    required this.services,
    required this.userId,
  }) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controller for the review text
  final TextEditingController _reviewController = TextEditingController();

  // Selected service for review
  Map<String, dynamic>? _selectedService;

  // Rating value
  double _rating = 3.0;

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Select the first service by default if available
    if (widget.services.isNotEmpty) {
      _selectedService = widget.services[0];
    }
  }

  // Format date-only from Timestamp
  String _formatDateOnly(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  // Submit the review
  Future<void> _submitReview() async {
    // Validate inputs
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service to review')),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review comment')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create review data
      final reviewData = {
        'userId': widget.userId,
        'bookingId': widget.bookingData['bookingId'],
        'serviceId': _selectedService!['serviceId'],
        'serviceName': _selectedService!['serviceName'],
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'customerName': widget.bookingData['customerName'],
        'createdAt': Timestamp.now(),
      };

      // Add to Reviews collection
      await _firestore.collection('Reviews').add(reviewData);

      // Update service average rating in Services collection
      DocumentReference serviceRef =
          _firestore.collection('Services').doc(_selectedService!['serviceId']);

      // Get the current service data
      DocumentSnapshot serviceDoc = await serviceRef.get();

      if (serviceDoc.exists) {
        Map<String, dynamic> serviceData =
            serviceDoc.data() as Map<String, dynamic>;

        // Calculate new average rating
        num currentRating = serviceData['averageRating'] ?? 0;
        int totalReviews = serviceData['totalReviews'] ?? 0;

        double newAverage =
            ((currentRating * totalReviews) + _rating) / (totalReviews + 1);

        // Update service with new rating info
        await serviceRef.update({
          'averageRating': newAverage,
          'totalReviews': totalReviews + 1,
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletOrDesktop = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Write a Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking summary card
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Booking Summary',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.bookingData['status'] ?? 'Pending',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Booking ID: ${widget.bookingData['bookingId'] ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Date: ${widget.bookingData['bookingDate'] != null ? _formatDateOnly(widget.bookingData['bookingDate']) : 'N/A'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Time Slot: ${widget.bookingData['timeSlot'] ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 14),
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
                                        Text(
                                          'Customer: ${widget.bookingData['customerName'] ?? 'N/A'}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Vehicle: ${widget.bookingData['vehicleModel'] ?? 'N/A'}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total: ₹${widget.bookingData['totalAmount'] ?? 'N/A'}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (!isTabletOrDesktop) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Customer: ${widget.bookingData['customerName'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vehicle: ${widget.bookingData['vehicleModel'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ₹${widget.bookingData['totalAmount'] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Text(
                      'Select Service to Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Service selection
                    widget.services.isEmpty
                        ? const Text('No services available to review')
                        : Container(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.services.length,
                              itemBuilder: (context, index) {
                                final service = widget.services[index];
                                final isSelected = _selectedService == service;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedService = service;
                                    });
                                  },
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(10),
                                              ),
                                              child: Image.network(
                                                service['imageUrl'] ?? '',
                                                height: 80,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: const Icon(Icons
                                                        .image_not_supported),
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                service['serviceName'] ?? 'N/A',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 24),

                    // Rating section
                    const Text(
                      'Your Rating',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _getRatingText(),
                        style: TextStyle(
                          fontSize: 16,
                          color: _getRatingColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Review text field
                    const Text(
                      'Your Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reviewController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Write your review here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getRatingText() {
    if (_rating <= 1) return 'Poor';
    if (_rating <= 2) return 'Fair';
    if (_rating <= 3) return 'Good';
    if (_rating <= 4) return 'Very Good';
    return 'Excellent';
  }

  Color _getRatingColor() {
    if (_rating <= 1) return Colors.red;
    if (_rating <= 2) return Colors.orange;
    if (_rating <= 3) return Colors.amber;
    if (_rating <= 4) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
