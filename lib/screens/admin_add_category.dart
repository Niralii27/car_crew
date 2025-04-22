import 'package:flutter/material.dart';

class AdminAddCategory extends StatelessWidget {
  const AdminAddCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car Service Category'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Name Field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter service name',
                ),
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              // Image Selection - Static version
              Container(
                height: screenHeight * 0.2,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: screenWidth * 0.1,
                      color: Colors.grey,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Text('Service Image'),
                  ],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              // Description Field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: 'Enter service description',
                ),
                maxLines: 5,
              ),
              
              SizedBox(height: screenHeight * 0.04),
              
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  // No functionality in static version
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                ),
                child: Text(
                  'SAVE CATEGORY',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}