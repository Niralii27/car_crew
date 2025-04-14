import 'package:flutter/material.dart';

class Selectvehicle extends StatefulWidget {
  const Selectvehicle({super.key});

  @override
  State<Selectvehicle> createState() => _SelectvehicleState();
}

class _SelectvehicleState extends State<Selectvehicle> {
  // Static local image data
  Future<List<Map<String, String>>> fetchVehicleBrands() async {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate loading
    return [
      {"name": "Maruti Suzuki", "logo": "assets/CarLogo/BMW.png"},
      {"name": "Hyundai", "logo": "assets/CarLogo/fiat.png"},
      {"name": "Honda", "logo": "assets/audi.png"},
      {"name": "TATA", "logo": "assets/CarLogo/toyota.png"},
      {"name": "Ford", "logo": "assets/CarLogo/volkswagen.png"},
      {"name": "Volkswagen", "logo": "assets/CarLogo/BMW.png"},
      {"name": "Mahindra", "logo": "assets/CarLogo/fiat.png"},
      {"name": "Renault", "logo": "assets/CarLogo/audi.png"},
      {"name": "Toyota", "logo": "assets/CarLogo/toyota.png"},
      {"name": "BMW", "logo": "assets/CarLogo/volkswagen.png"},
      {"name": "KIA", "logo": "assets/CarLogo/BMW.png"},
      {"name": "Jeep", "logo": "assets/CarLogo/toyota.png"},
      {"name": "Mahindra", "logo": "assets/CarLogo/fiat.png"},
      {"name": "Renault", "logo": "assets/CarLogo/audi.png"},
      {"name": "Toyota", "logo": "assets/CarLogo/toyota.png"},
      // Add more as needed...
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = (width / 100).floor().clamp(2, 5);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: const Text("Select Your Vehicle",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Vehicle Model or Brand',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: fetchVehicleBrands(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (snapshot.hasError)
                  return Center(child: Text("Error loading data"));

                final brands = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: brands.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return GestureDetector(
                      onTap: () {
                        print("Selected brand: ${brand['name']}");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          brand['logo']!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image,
                                size: 50, color: Colors.red);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
