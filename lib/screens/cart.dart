import 'package:car_crew/screens/checkout.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Sample cart items (you will replace with your actual data model)
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      serviceName: 'Oil Change',
      price: 999,
      imageUrl: 'assets/images/oil_change.png',
    ),
    CartItem(
      id: '2',
      serviceName: 'Wheel Alignment',
      price: 1499,
      imageUrl: 'assets/images/wheel_alignment.png',
    ),
    CartItem(
      id: '3',
      serviceName: 'Full Car Service',
      price: 3999,
      imageUrl: 'assets/images/full_service.png',
    ),
  ];

  // Calculate total price
  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.price);
  }

  // Remove item from cart
  void removeItem(String id) {
    setState(() {
      cartItems.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service removed from cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.blue[800],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(screenSize)
          : _buildCartContent(screenSize, isSmallScreen),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : _buildCheckoutBar(context, screenSize, isSmallScreen),
    );
  }

  Widget _buildEmptyCart(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: screenSize.width * 0.25,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: screenSize.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add services to your cart to proceed',
            style: TextStyle(
              fontSize: screenSize.width * 0.035,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to services page
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Browse Services'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(Size screenSize, bool isSmallScreen) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 20),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItemCard(item, screenSize, isSmallScreen);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(
      CartItem item, Size screenSize, bool isSmallScreen) {
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Service image
            Container(
              width: isSmallScreen ? 70 : 100,
              height: isSmallScreen ? 70 : 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, _) => Icon(
                    Icons.car_repair,
                    size: isSmallScreen ? 40 : 60,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.serviceName,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              onPressed: () => removeItem(item.id),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              iconSize: isSmallScreen ? 22 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(
      BuildContext context, Size screenSize, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 15 : 25,
        vertical: isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: isSmallScreen
                  ? screenSize.width * 0.4
                  : screenSize.width * 0.3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                        cartItems: [],
                        totalAmount: 500,
                      ),
                    ),
                  );
                  // Handle checkout logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Proceeding to checkout...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for cart items
class CartItem {
  final String id;
  final String serviceName;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.imageUrl,
  });
}

// Example usage in your main app
class CarServiceApp extends StatelessWidget {
  const CarServiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Service App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CartPage(),
    );
  }
}

void main() {
  runApp(const CarServiceApp());
}
