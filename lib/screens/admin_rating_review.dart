import 'package:car_crew/screens/admin_review_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Review {
  final String bookingId;
  final Timestamp createdAt;
  final String customerName;
  final double rating;
  final String review;
  final String serviceId;
  final String serviceName;
  final String userId;

  Review({
    required this.bookingId,
    required this.createdAt,
    required this.customerName,
    required this.rating,
    required this.review,
    required this.serviceId,
    required this.serviceName,
    required this.userId,
  });

  factory Review.fromFirestore(Map<String, dynamic> data) {
    return Review(
      bookingId: data['bookingId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      customerName: data['customerName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      review: data['review'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}

class AdminRatingsAndReviews extends StatefulWidget {
  @override
  _AdminRatingsAndReviewsState createState() => _AdminRatingsAndReviewsState();
}

class _AdminRatingsAndReviewsState extends State<AdminRatingsAndReviews> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Review> _reviews = [];
  bool _isLoading = true;
  Map<String, double> _averageRatings = {
    'Cleanliness': 0.0,
    'Maintenance': 0.0,
    'Communication': 0.0,
    'Convenience': 0.0,
    'Listing accuracy': 0.0,
  };
  double _overallRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch reviews from Firestore
      QuerySnapshot querySnapshot =
          await _firestore.collection('Reviews').get();

      List<Review> reviews = querySnapshot.docs
          .map(
              (doc) => Review.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort reviews by createdAt timestamp (newest first)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Calculate average rating
      if (reviews.isNotEmpty) {
        double sum = reviews.fold(0.0, (sum, review) => sum + review.rating);
        _overallRating = sum / reviews.length;

        // For demonstration, simulate category ratings based on overall
        // In a real app, you might have separate fields for these categories
        _averageRatings = {
          'Cleanliness': _overallRating - 0.1,
          'Maintenance': _overallRating,
          'Communication': _overallRating - 0.1,
          'Convenience': _overallRating,
          'Listing accuracy': _overallRating,
        };
      }

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rating and Reviews",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(_overallRating.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 4),
                      Text("(${_reviews.length} ratings)",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildRatingRow(
                      "Cleanliness", _averageRatings['Cleanliness']!),
                  _buildRatingRow(
                      "Maintenance", _averageRatings['Maintenance']!),
                  _buildRatingRow(
                      "Communication", _averageRatings['Communication']!),
                  _buildRatingRow(
                      "Convenience", _averageRatings['Convenience']!),
                  _buildRatingRow(
                      "Listing accuracy", _averageRatings['Listing accuracy']!),
                  SizedBox(height: 20),
                  Text("Reviews (${_reviews.length} reviews)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  ..._reviews
                      .map((review) => _buildReviewCard(review))
                      .toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildRatingRow(String title, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 5,
            child: LinearProgressIndicator(
              value: rating / 5.0,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 6,
            ),
          ),
          SizedBox(width: 10),
          Text(rating.toStringAsFixed(1),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    // Format the timestamp
    String formattedDate =
        DateFormat('dd MMMM yyyy').format(review.createdAt.toDate());

    return GestureDetector(
      onTap: () {
        // Navigate to specific review page when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SpecificReviewPage(bookingId: review.bookingId),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      review.customerName.isNotEmpty
                          ? review.customerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    radius: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                              5,
                              (index) => Icon(
                                  index < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16)),
                        ),
                        SizedBox(height: 2),
                        Text("${review.customerName}  •  $formattedDate",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                        if (review.serviceName.isNotEmpty)
                          Text(
                            "Service: ${review.serviceName}",
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                review.review,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // FirebaseApp.initializeApp(); // This should be called in your actual main.dart

  runApp(MaterialApp(
    home: AdminRatingsAndReviews(),
  ));
}
