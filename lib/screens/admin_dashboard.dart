import 'dart:async';
import 'package:car_crew/screens/admin_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? userId;
  String userName = "Admin";
  String userImage = "";

  // Data streams
  late Stream<QuerySnapshot> _bookingsStream;
  late Stream<QuerySnapshot> _reviewsStream;

  // Counters
  int userCount = 0;
  int bookingCount = 0;
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();

    // Get the arguments passed from the login page
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      userId = args['userId'];
      print("User ID received: $userId");

      // Fetch user data once we have the ID
      if (userId != null) {
        fetchUserName();
      }
    }

    // Initialize Firestore streams
    _bookingsStream = FirebaseFirestore.instance
        .collection('Booking')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();

    _reviewsStream = FirebaseFirestore.instance
        .collection('Reviews')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();

    // Fetch dashboard metrics
    fetchDashboardMetrics();
  }

  Future<void> fetchUserName() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('UsersTbl')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['UserName'] ?? "Admin";
          userImage = userData['UserImage'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  Future<void> fetchDashboardMetrics() async {
    try {
      // Fetch user count
      final userSnapshot =
          await FirebaseFirestore.instance.collection('UsersTbl').get();

      // Fetch booking count and total revenue
      final bookingsSnapshot =
          await FirebaseFirestore.instance.collection('Booking').get();

      double revenue = 0;
      for (var doc in bookingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        if (data.containsKey('totalAmount')) {
          revenue += (data['totalAmount'] as num).toDouble();
        }
      }

      setState(() {
        userCount = userSnapshot.size;
        bookingCount = bookingsSnapshot.size;
        totalRevenue = revenue;
      });
    } catch (e) {
      print("Error fetching dashboard metrics: $e");
    }
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with simple styling
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Profile Picture / Menu Opener
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(_createSidePanelRoute());
                            },
                            child: CircleAvatar(
                              radius: deviceWidth * 0.06,
                              backgroundImage: userImage.isNotEmpty
                                  ? NetworkImage(userImage)
                                  : AssetImage('assets/profile.png')
                                      as ImageProvider,
                              backgroundColor: Colors.blue[100],
                            ),
                          ),
                          SizedBox(width: deviceWidth * 0.03),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Dashboard Title
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    "Dashboard Overview",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),

                // Summary Cards Row
                Row(
                  children: [
                    _buildDashboardCard(
                      Icons.people,
                      'Users',
                      userCount.toString(),
                      Colors.blue,
                    ),
                    SizedBox(width: 10),
                    _buildDashboardCard(
                      Icons.car_repair,
                      'Bookings',
                      bookingCount.toString(),
                      Colors.green,
                    ),
                    SizedBox(width: 10),
                    _buildDashboardCard(
                      Icons.attach_money,
                      'Revenue',
                      '₹${totalRevenue.toStringAsFixed(1)}k',
                      Colors.orange,
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Tab Bar with improved styling
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[800],
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.calendar_today, size: 20),
                        text: 'Recent Bookings',
                      ),
                      Tab(
                        icon: Icon(Icons.star, size: 20),
                        text: 'Latest Reviews',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Tab Content
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: TabBarView(
                    children: [
                      // Bookings Tab
                      StreamBuilder<QuerySnapshot>(
                        stream: _bookingsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error loading bookings'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('No bookings found'),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.only(top: 8),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var booking = snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                              var services =
                                  booking['services'] as List<dynamic>;
                              var serviceName = services.isNotEmpty
                                  ? services[0]['serviceName']
                                  : 'Unknown Service';

                              // Determine status color
                              Color statusColor;
                              String status = booking['status'] ?? 'Unknown';
                              switch (status.toLowerCase()) {
                                case 'completed':
                                  statusColor = Colors.green;
                                  break;
                                case 'pending':
                                  statusColor = Colors.orange;
                                  break;
                                case 'cancelled':
                                  statusColor = Colors.red;
                                  break;
                                default:
                                  statusColor = Colors.grey;
                              }

                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 6),
                                child: ExpansionTile(
                                  leading: Icon(Icons.car_rental,
                                      color: Colors.blue),
                                  title: Text(
                                    booking['customerName'] ??
                                        'Unknown Customer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(serviceName),
                                      SizedBox(height: 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    '₹${booking['totalAmount'] ?? 0}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildBookingDetailRow(
                                            'Date',
                                            formatDate(booking['bookingDate']),
                                            Icons.calendar_today,
                                          ),
                                          _buildBookingDetailRow(
                                            'Time Slot',
                                            booking['timeSlot'] ??
                                                'Not specified',
                                            Icons.access_time,
                                          ),
                                          _buildBookingDetailRow(
                                            'Vehicle',
                                            booking['vehicleModel'] ??
                                                'Not specified',
                                            Icons.directions_car,
                                          ),
                                          _buildBookingDetailRow(
                                            'Address',
                                            booking['address'] ??
                                                'Not specified',
                                            Icons.location_on,
                                          ),
                                          _buildBookingDetailRow(
                                            'Payment',
                                            '${booking['paymentMethod'] ?? 'Not specified'} - ${booking['paymentStatus'] ?? 'Not specified'}',
                                            Icons.payment,
                                          ),
                                          _buildBookingDetailRow(
                                            'Phone',
                                            booking['phoneNumber'] ??
                                                'Not specified',
                                            Icons.phone,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Reviews Tab
                      StreamBuilder<QuerySnapshot>(
                        stream: _reviewsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error loading reviews'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('No reviews found'),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.only(top: 8),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var review = snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                              int rating = (review['rating'] ?? 0).toInt();
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            review['customerName'] ??
                                                'Unknown Customer',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.amber.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star,
                                                    color: Colors.amber,
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Text('$rating'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          review['serviceName'] ??
                                              'Unknown Service',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(review['review'] ?? 'No comment'),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 14, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(
                                            formatDate(review['createdAt']),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      _buildRatingStars(rating),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(num rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildDashboardCard(
      IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PageRouteBuilder _createSidePanelRoute() {
  return PageRouteBuilder(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AdminSidenavBar(),
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
