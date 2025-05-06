import 'package:car_crew/screens/sideNavbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get/get.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? userId;
  String userName = "User";
  String userImage = "User";
  String? imageUrl;

  // List to store reviews
  List<Map<String, dynamic>> reviews = [];
  bool isLoadingReviews = true;

  late PageController _pageController;
  int currentIndex = 0;

  List<String> images = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider1.png',
  ];

  final List<Map<String, String>> services = [
    {'icon': 'assets/service_icon1.png', 'label': 'Light Fix'},
    {'icon': 'assets/service_icon2.png', 'label': 'Wheel Care'},
    {'icon': 'assets/service_icon6.png', 'label': 'Denting & Painting'},
    {'icon': 'assets/service_icon3.png', 'label': 'AC Service'},
    {'icon': 'assets/service_icon7.png', 'label': 'Car Wash'},
    {'icon': 'assets/service_icon8.png', 'label': 'Battery'},
    {'icon': 'assets/service_icon4.png', 'label': 'Insurance Claim'},
    {'icon': 'assets/service_icon5.png', 'label': 'Oiling'},
  ];

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

    //car profile image
    fetchProfileImage();

    // Fetch reviews
    fetchReviews();

    _pageController = PageController(initialPage: 0);

    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = currentIndex + 1;

        if (nextPage >= images.length) {
          // Jump to the first image without animation
          _pageController.jumpToPage(0);
          currentIndex = 0;
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          currentIndex = nextPage;
        }
      }
    });
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
          // Replace 'UserName' with whatever field you use in your Firestore
          userName = userData['UserName'] ?? "User";
          userImage = userData['UserImage'] ?? ""; // Yeh line add karni hai
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

// Fetch reviews from Firestore
  Future<void> fetchReviews() async {
    setState(() {
      isLoadingReviews = true;
    });

    try {
      // Get the top 5 reviews ordered by date (most recent first)
      final QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('Reviews')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> fetchedReviews = [];

      for (var doc in reviewSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Format timestamp to readable date
        String formattedDate = "Recent";
        if (data['createdAt'] != null) {
          Timestamp timestamp = data['createdAt'] as Timestamp;
          DateTime dateTime = timestamp.toDate();
          formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
        }

        fetchedReviews.add({
          'id': doc.id,
          'customerName': data['customerName'] ?? 'Anonymous',
          'rating': data['rating'] ?? 0,
          'review': data['review'] ?? 'No review text',
          'serviceName': data['serviceName'] ?? 'Unknown Service',
          'date': formattedDate,
        });
      }

      setState(() {
        reviews = fetchedReviews;
        isLoadingReviews = false;
      });
    } catch (e) {
      print("Error fetching reviews: $e");
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

//fetch the car profile image
  Future<void> fetchProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('carProfile')
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          imageUrl = snapshot.docs.first['imageUrl'];
        });
      }
    }
  }

  // Widget to display star rating
  Widget buildRatingStars(num rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  // Widget to build indicator dots for slider
  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: images.asMap().entries.map((entry) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == entry.key
                ? Colors.blue.shade600
                : Colors.grey.shade400,
          ),
        );
      }).toList(),
    );
  }

  // Widget to build review card for horizontal scroll
  Widget buildReviewCard(Map<String, dynamic> review) {
    return Container(
      width: 280,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      review['customerName'][0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['customerName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          review['date'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildRatingStars(review['rating']),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      review['serviceName'],
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: Text(
                  review['review'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on device width
    final double headerPadding = deviceWidth * 0.04;
    final double cardElevation = deviceWidth > 600 ? 3.0 : 2.0;
    final double avatarSize = deviceWidth * 0.06;
    final double headerFontSize = deviceWidth > 600 ? 22.0 : deviceWidth * 0.05;
    final double servicePadding = deviceWidth > 600 ? 20.0 : 12.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar with elegant design
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: headerPadding,
                        vertical: deviceHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Logo with tap effect for side panel
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    _createSidePanelRoute(),
                                  );
                                },
                                customBorder: CircleBorder(),
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: avatarSize,
                                    backgroundImage: userImage.isNotEmpty
                                        ? NetworkImage(userImage)
                                        : AssetImage('assets/profile.png')
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                              SizedBox(width: deviceWidth * 0.03),

                              // Greeting and Name with typography
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back',
                                    style: TextStyle(
                                      fontSize: deviceWidth * 0.03,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: deviceWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Car profile image with elegant border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: avatarSize,
                              backgroundColor: Colors.white,
                              backgroundImage: imageUrl != null
                                  ? NetworkImage(imageUrl!)
                                  : AssetImage('assets/car_profile.png')
                                      as ImageProvider,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search bar with elegant design
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: headerPadding, vertical: 16),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.blue[400]), // Search Icon
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search for services...",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.mic,
                                color: Colors.blue[600], size: 20),
                          ),
                        ],
                      ),
                    ),

                    // Image Slider with elegant design
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: headerPadding),
                      height: deviceHeight * 0.22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.asset(
                              images[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),

                    // Indicator dots
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: buildIndicator(),
                    ),

                    // Services section with elegant header
                    Padding(
                      padding: EdgeInsets.only(
                        left: headerPadding,
                        right: headerPadding,
                        top: 16,
                        bottom: 8,
                      ),
                      child: Text(
                        'Select Services',
                        style: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),

                    // Services grid with elegant cards
                    Container(
                      height: deviceHeight * 0.32, // Adjusted height
                      padding:
                          EdgeInsets.symmetric(horizontal: headerPadding / 2),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(servicePadding / 2),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: deviceWidth > 600 ? 0.8 : 0.7,
                          crossAxisSpacing: servicePadding / 2,
                          mainAxisSpacing: servicePadding / 2,
                        ),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: cardElevation,
                            shadowColor: Colors.blue.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    services[index]['icon']!,
                                    width: deviceWidth * 0.09,
                                    height: deviceWidth * 0.09,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    services[index]['label']!,
                                    style: TextStyle(
                                      fontSize: deviceWidth * 0.025,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Reviews Section Header with elegant design
                    Padding(
                      padding: EdgeInsets.only(
                        left: headerPadding,
                        right: headerPadding,
                        top: 0, // Reduced space between services and reviews
                        bottom: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customer Reviews',
                            style: TextStyle(
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to all reviews page
                              print("Show all reviews");
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                                fontSize: deviceWidth * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Horizontal scrolling reviews with elegant cards
                    Container(
                      height: 160,
                      margin: EdgeInsets.only(bottom: 16),
                      child: isLoadingReviews
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : reviews.isEmpty
                              ? Center(
                                  child: Text(
                                    "No reviews yet",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  itemCount: reviews.length,
                                  itemBuilder: (context, index) {
                                    return buildReviewCard(reviews[index]);
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Create a custom route for the side panel
PageRouteBuilder _createSidePanelRoute() {
  return PageRouteBuilder(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Sidenavbar(),
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
