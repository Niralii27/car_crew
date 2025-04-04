import 'package:flutter/material.dart';

class Servicesdetails extends StatefulWidget {
  const Servicesdetails({super.key});

  @override
  State<Servicesdetails> createState() => _ServicesDetailsState();
}

class _ServicesDetailsState extends State<Servicesdetails> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Services details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: deviceWidth * 0.06,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              CarServiceCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class CarServiceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9, // Adjust width based on screen size
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Car service",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Every 10000 Kms / 5 Months",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  "Includes 15 services",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  "Takes 5 Hours",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "\$70",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "\$50",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "assets/car_service_img1.png", // Replace with actual image URL
                    height: 80,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: Text("ADD"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
