import 'package:flutter/material.dart';

class CarDetailPage extends StatefulWidget {
  const CarDetailPage({super.key});

  @override
  _CarDetailPageState createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  bool isPasswordVisible = false;

  TextEditingController modelController =
      TextEditingController(text: 'Fortuner');
  TextEditingController companyController =
      TextEditingController(text: 'Toyota');
  TextEditingController colorController = TextEditingController(text: 'Black');
  TextEditingController numberplateController =
      TextEditingController(text: 'GJ 03 NI 2717');
  TextEditingController passwordController =
      TextEditingController(text: '123456789');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/fortuner.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Model:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: modelController,
              decoration: InputDecoration(
                hintText: 'Enter your car Model',
                prefixIcon:
                    Icon(Icons.car_crash_rounded, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Company:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: companyController,
              decoration: InputDecoration(
                hintText: 'Enter your car CompanyName',
                prefixIcon: Icon(Icons.branding_watermark_sharp,
                    color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Color:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: colorController,
              decoration: InputDecoration(
                hintText: 'Enter your car Color',
                prefixIcon: Icon(Icons.format_color_fill_sharp,
                    color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Number Plate:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: numberplateController,
              decoration: InputDecoration(
                hintText: 'Enter your car Numberplate No.',
                prefixIcon:
                    Icon(Icons.numbers_rounded, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Password:',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to change password
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Change Password',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
