import 'package:car_crew/screens/admin_add_category.dart';
import 'package:flutter/material.dart';

class AdminServices extends StatelessWidget {
  final List<Service> services = [
    Service(
      title: "Car service",
      description:
          "Every 10000 Kms / 5 Months\nIncludes 15 services\nTakes 5 Hours",
      oldPrice: "\$70",
      newPrice: "\$50",
      imageUrl: "assets/car_service_img1.png",
    ),
    Service(
      title: "Wheel Care",
      description: "5 Years warranty\nTubeless\nFitting cost included",
      oldPrice: "\$90",
      newPrice: "\$70",
      imageUrl: "assets/car_service_img1.png",
    ),
    Service(
      title: "Ac Service",
      description: "Every 3 Months\nRecommended\nTakes 4 Hours",
      oldPrice: "\$70",
      newPrice: "\$50",
      imageUrl: "assets/car_service_img1.png",
    ),
  ];

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
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return ServiceCard(service: services[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Service {
  final String title;
  final String description;
  final String oldPrice;
  final String newPrice;
  final String imageUrl;

  Service({
    required this.title,
    required this.description,
    required this.oldPrice,
    required this.newPrice,
    required this.imageUrl,
  });
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({Key? key, required this.service}) : super(key: key);

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
                  Row(
                    children: [
                      Text(
                        service.oldPrice,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                      SizedBox(width: 8),
                      Text(
                        service.newPrice,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(service.imageUrl,
                  width: 70, height: 70, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
