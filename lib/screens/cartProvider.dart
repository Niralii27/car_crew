import 'package:flutter/foundation.dart';

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

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items {
    return [..._items];
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  void addItem({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
  }) {
    // Check if item already exists in cart
    final existingItemIndex = _items.indexWhere((item) => item.id == id);
    
    if (existingItemIndex >= 0) {
      // Item already exists in cart
      // You could implement quantity increase here if needed
      notifyListeners();
      return;
    }
    
    // Add new item to cart
    _items.add(
      CartItem(
        id: id,
        serviceName: name,
        price: price,
        imageUrl: imageUrl,
      ),
    );
    
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}