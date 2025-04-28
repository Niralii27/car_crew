import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_crew/screens/cartProvider.dart';
import 'package:car_crew/screens/checkout.dart' as checkout;

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.blue[800],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final userCartItems =
              cart.items.where((item) => item.userId == userId).toList();

          if (userCartItems.isEmpty) {
            return _buildEmptyCart(screenSize, context);
          } else {
            return _buildCartContent(
                screenSize, isSmallScreen, cart, userCartItems);
          }
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return SizedBox.shrink(); // Return an empty widget instead of null
          } else {
            return _buildCheckoutBar(context, screenSize, isSmallScreen, cart);
          }
        },
      ),
    );
  }

  Widget _buildEmptyCart(Size screenSize, BuildContext context) {
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

  Widget _buildCartContent(Size screenSize, bool isSmallScreen,
      CartProvider cart, List<CartItem> userCartItems) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 20),
            itemCount: userCartItems.length,
            itemBuilder: (context, index) {
              final item = userCartItems[index];
              return _buildCartItemCard(
                  item, screenSize, isSmallScreen, cart, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, Size screenSize, bool isSmallScreen,
      CartProvider cart, BuildContext context) {
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
                child: Image.network(
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
              onPressed: () {
                final userId = FirebaseAuth.instance.currentUser?.uid;

                cart.removeItem(item.id, item.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service removed from cart')),
                );
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              iconSize: isSmallScreen ? 22 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, Size screenSize,
      bool isSmallScreen, CartProvider cart) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
                    '₹${cart.items.where((item) => item.userId == userId).fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)}',
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
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  // Convert CartItem to checkout.CartItem
                  List<checkout.CartItem> checkoutItems = cart.items
                      .where((item) => item.userId == userId)
                      .map((item) => checkout.CartItem(
                            id: item.id,
                            serviceName: item.serviceName,
                            price: item.price,
                            imageUrl: item.imageUrl,
                          ))
                      .toList();

                  double userTotalAmount =
                      checkoutItems.fold(0.0, (sum, item) => sum + item.price);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => checkout.CheckoutPage(
                        cartItems: checkoutItems,
                        totalAmount: userTotalAmount,
                      ),
                    ),
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
