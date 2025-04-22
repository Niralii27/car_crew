import 'package:flutter/material.dart';

class AdminCarBook extends StatelessWidget {
  final List<Map<String, dynamic>> carBookings = [
    {
      "image": "assets/car1.jpg",
      "name": "Tesla Roadster",
      "dueDate": "Due on 11 Sep, 2023",
      "owner": "Chris",
      "phone": "+1202-555-0877",
      "status": "In Use",
      "statusColor": Colors.blue,
    },
    {
      "image": "assets/car2.jpg",
      "name": "BMW X6 2018",
      "dueDate": "Due on 16 Sep, 2023",
      "owner": "Chris",
      "phone": "+1202-555-0877",
      "status": "Completed",
      "statusColor": Colors.green,
    },
    {
      "image": "assets/car3.jpg",
      "name": "Audi RS 5",
      "dueDate": "Due on 11 Sep, 2023",
      "owner": "Chris",
      "phone": "+1202-555-0877",
      "status": "In Use",
      "statusColor": Colors.blue,
    },
  ];

  final List<Map<String, dynamic>> statistics = [
    {"icon": Icons.people, "value": "20", "label": "Total Customers"},
    {"icon": Icons.shopping_cart, "value": "27", "label": "Total Orders"},
    {"icon": Icons.attach_money, "value": "\$2,000", "label": "Total Income"},
    {"icon": Icons.money_off, "value": "\$425", "label": "Total Expense"},
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
        title: Text("Car Booking", style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text("ADD CAR", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            SizedBox(height: 16),
            ...carBookings.map((car) => _buildCarCard(car)).toList(),
            SizedBox(height: 20),
            Text("Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                car["image"],
                width: 80,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car["name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(car["dueDate"], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(car["owner"], style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(car["phone"], style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: car["statusColor"].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                car["status"],
                style: TextStyle(fontSize: 14, color: car["statusColor"], fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: statistics.length,
      itemBuilder: (context, index) {
        final stat = statistics[index];
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(stat["icon"], color: Colors.blue, size: 24),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat["value"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(stat["label"], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminCarBook(),
  ));
}
