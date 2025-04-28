import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String serviceName;
  final double price;
  final String imageUrl;
  final String userId;

  CartItem({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.imageUrl,
    required this.userId, 
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
    required String userId,
    required String id,
    required String name,
    required double price,
    required String imageUrl,
  }) {
    // Check if the same item is already in the current user's cart
    final existingItemIndex = _items.indexWhere(
      (item) => item.id == id && item.userId == userId
    );
    
    if (existingItemIndex >= 0) {
      // Item already exists in this user's cart
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
        userId: userId,
      ),
    );
    
    notifyListeners();
  }

  List<CartItem> getItemsForUser(String userId) {
    return _items.where((item) => item.userId == userId).toList();
  }

  double getTotalAmountForUser(String userId) {
    return _items
        .where((item) => item.userId == userId)
        .fold(0.0, (sum, item) => sum + item.price);
  }

  void removeItem(String id, String userId) {
    _items.removeWhere((item) => item.id == id && item.userId == userId);
    notifyListeners();
  }

  void clearUserCart(String userId) {
    _items.removeWhere((item) => item.userId == userId);
    notifyListeners();
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}