import 'package:flutter/material.dart';

class AdminShowBooking extends StatelessWidget {
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
        title: Text("Show Booking", style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            _buildBookingCard(),
            SizedBox(height: 20),
            _buildBookingCard(), 
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _buildHostInfo(),
            SizedBox(height: 12),
            _buildTripDetail(
              icon: Icons.calendar_today_outlined,
              text: "10 Aug to 17 Aug",
              actionText: "Add Dates",
            ),
            SizedBox(height: 10),
            _buildTripDetail(
              icon: Icons.location_on_outlined,
              text: "Los Angeles, CA 91602",
              actionText: "Change",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage("assets/avatar.jpg"), // Replace with actual image
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Felicia Lopez", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 14),
                  SizedBox(width: 4),
                  Text("5.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Text("🏆 All-Star Host", style: TextStyle(fontSize: 14, color: Colors.blue)),
              Text("139 Trips • Joined Sep 2020", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text("Typically responds in 15 minutes", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        Icon(Icons.call, color: Colors.blue, size: 24),
      ],
    );
  }

  Widget _buildTripDetail({required IconData icon, required String text, required String actionText}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(text, style: TextStyle(fontSize: 14)),
            ],
          ),
          Text(actionText, style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminShowBooking(),
  ));
}
