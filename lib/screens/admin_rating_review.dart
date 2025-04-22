import 'package:flutter/material.dart';

class AdminRatingsAndReviews extends StatelessWidget {
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rating and Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Text("5.00", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.star, color: Colors.amber, size: 24),
                SizedBox(width: 4),
                Text("(4 ratings)", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            SizedBox(height: 12),
            _buildRatingRow("Cleanliness", 4.9),
            _buildRatingRow("Maintenance", 5.0),
            _buildRatingRow("Communication", 4.9),
            _buildRatingRow("Convenience", 5.0),
            _buildRatingRow("Listing accuracy", 5.0),
            SizedBox(height: 20),
            Text("Reviews (56 reviews)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildReviewCard(),
            _buildReviewCard(),
            _buildReviewCard(),
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
          Text(rating.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Card(
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
                  backgroundImage: AssetImage("assets/avatar.jpg"), 
                  radius: 20,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) => Icon(Icons.star, color: Colors.amber, size: 16)),
                    ),
                    SizedBox(height: 2),
                    Text("Felicia  •  20 July 2023", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Lorem Ipsum is simply dummy text of the printing and type that setting industry. Lorem Ipsum has been the industry’s standard dummy text ever since.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminRatingsAndReviews(),
  ));
}
