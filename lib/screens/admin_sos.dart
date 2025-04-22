import 'package:flutter/material.dart';

class AdminSos extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      "title": "Car service",
      "description": "Every 10000 Kms / 5 Months\nIncludes 15 services\nTakes 5 Hours",
      "image": "assets/car_service1.jpg",
      "oldPrice": "\$70",
      "newPrice": "\$50",
    },
    {
      "title": "Wheel Care",
      "description": "5 Years warranty\nTubeless\nFitting cost included",
      "image": "assets/car_service1.jpg",
      "oldPrice": "\$90",
      "newPrice": "\$70",
    },
  ];

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
        title: Text("SOS", style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Add location",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Center(
                child: Text("ADD EMERGENCY SERVICES", style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service["title"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(service["description"], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        service["oldPrice"],
                        style: TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough),
                      ),
                      SizedBox(width: 6),
                      Text(
                        service["newPrice"],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                service["image"],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminSos(),
  ));
}
