import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReviewDetails {
  final String bookingId;
  final Timestamp createdAt;
  final String customerName;
  final double rating;
  final String review;
  final String serviceId;
  final String serviceName;
  final String userId;
  final String serviceImageUrl; // Added service image URL

  ReviewDetails({
    required this.bookingId,
    required this.createdAt,
    required this.customerName,
    required this.rating,
    required this.review,
    required this.serviceId,
    required this.serviceName,
    required this.userId,
    required this.serviceImageUrl, // Added to constructor
  });

  factory ReviewDetails.fromFirestore(Map<String, dynamic> data) {
    return ReviewDetails(
      bookingId: data['bookingId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      customerName: data['customerName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      review: data['review'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      userId: data['userId'] ?? '',
      serviceImageUrl: data['serviceImageUrl'] ??
          '', // Default to empty string if not available
    );
  }
}

class SpecificReviewPage extends StatefulWidget {
  final String bookingId;

  const SpecificReviewPage({Key? key, required this.bookingId})
      : super(key: key);

  @override
  _SpecificReviewPageState createState() => _SpecificReviewPageState();
}

class _SpecificReviewPageState extends State<SpecificReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ReviewDetails? _review;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch specific review by bookingId
      QuerySnapshot reviewSnapshot = await _firestore
          .collection('Reviews')
          .where('bookingId', isEqualTo: widget.bookingId)
          .limit(1)
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> reviewData =
            reviewSnapshot.docs.first.data() as Map<String, dynamic>;

        // Check if serviceImageUrl exists in review data
        if (reviewData.containsKey('serviceImageUrl')) {
          // Use the image URL directly from the review data
          setState(() {
            _review = ReviewDetails.fromFirestore(reviewData);
            _isLoading = false;
          });
        } else {
          // If serviceImageUrl is not in review data, fetch it from Services collection
          String serviceId = reviewData['serviceId'] ?? '';
          if (serviceId.isNotEmpty) {
            DocumentSnapshot serviceSnapshot =
                await _firestore.collection('Services').doc(serviceId).get();

            if (serviceSnapshot.exists) {
              Map<String, dynamic> serviceData =
                  serviceSnapshot.data() as Map<String, dynamic>;

              // Add image URL to review data
              reviewData['serviceImageUrl'] = serviceData['imageUrl'] ?? '';
            }
          }

          setState(() {
            _review = ReviewDetails.fromFirestore(reviewData);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No review found with this booking ID';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching review: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _buildReviewDetails(),
    );
  }

  Widget _buildReviewDetails() {
    if (_review == null) {
      return Center(child: Text('No review data available'));
    }

    // Format the timestamp
    String formattedDate =
        DateFormat('dd MMMM yyyy at HH:mm').format(_review!.createdAt.toDate());

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            _review!.customerName.isNotEmpty
                                ? _review!.customerName[0].toUpperCase()
                                : '?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          radius: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _review!.customerName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < _review!.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _review!.rating.toString(),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Review:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _review!.review,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Service Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service image
                    if (_review!.serviceImageUrl.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _review!.serviceImageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    if (_review!.serviceImageUrl.isNotEmpty)
                      SizedBox(height: 16),
                    _buildInfoRow('Service Name', _review!.serviceName),
                    Divider(),
                    _buildInfoRow('Service ID', _review!.serviceId),
                    Divider(),
                    _buildInfoRow('Booking ID', _review!.bookingId),
                    Divider(),
                    _buildInfoRow('User ID', _review!.userId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage
void main() {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // FirebaseCore.initializeApp(); // Make sure to initialize Firebase

  runApp(MaterialApp(
    home: SpecificReviewPage(bookingId: 'T8xWCyhfI1ptmwWpEDBu'),
  ));
}
