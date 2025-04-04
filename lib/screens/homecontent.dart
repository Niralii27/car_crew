import 'package:flutter/material.dart';
import 'dart:async';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late PageController _pageController;
  int currentIndex = 0;

  List<String> images = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider1.png',
  ];

  final List<Map<String, String>> services = [
    {'icon': 'assets/service_icon1.png', 'label': 'Car Service'},
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

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth * 0.04,
                        vertical: deviceHeight * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Logo
                              CircleAvatar(
                                radius: deviceWidth * 0.07,
                                backgroundImage:
                                    AssetImage('assets/profile.png'),
                              ),
                              SizedBox(width: deviceWidth * 0.03),

                              // Name
                              Text(
                                'Nirali Akbari',
                                style: TextStyle(
                                  fontSize: deviceWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Notification Icon
                          CircleAvatar(
                            radius: deviceWidth * 0.07,
                            backgroundImage:
                                AssetImage('assets/car_profile.png'),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50], // Light background color
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: Colors.blue.shade300), // Optional border
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.grey[600]), // Search Icon
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(Icons.mic,
                              color: Colors.grey[600]), // Microphone Icon
                        ],
                      ),
                    ),
                    SizedBox(
                      height: deviceHeight * 0.01,
                    ),
                    Container(
                      height: 200, // Fixed height (can be adjusted)
                      width: double.infinity, // Full width
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: deviceHeight * 0.01,
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: deviceWidth * 0.04),
                            child: Text(
                              'Select Services',
                              style: TextStyle(
                                fontSize: deviceWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            height:
                                deviceHeight * 0.35, // Adjust height as needed
                            child: GridView.builder(
                              physics:
                                  NeverScrollableScrollPhysics(), // Prevent scrolling
                              padding: EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4, // 4 items per row
                                childAspectRatio: 0.7, // Adjusted to fit name
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        services[index]['icon']!,
                                        width: 50,
                                        height: 50,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        services[index]['label']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: deviceHeight * 0.01,
                    ),
                    // Container(
                    //   child: Column(
                    //     children: [
                    //       Text(
                    //         'Car Booking',
                    //         style: TextStyle(
                    //           fontSize: deviceWidth * 0.06,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
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
