// lib/controller/user_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController1 extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final RxMap<String, dynamic> _userData = RxMap<String, dynamic>({});
  
  User? get user => _firebaseUser.value;
  Map<String, dynamic> get userData => _userData;
  String? get userId => _firebaseUser.value?.uid;
  
  @override
  void onInit() {
    super.onInit();
    _firebaseUser.value = _auth.currentUser;
    ever(_firebaseUser, _setInitialScreen);
  }
  
  void _setInitialScreen(User? user) {
    if (user != null) {
      fetchUserData(user.uid);
    }
  }
  
  void setUser(User? user) {
    _firebaseUser.value = user;
  }
  
  Future<void> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('UsersTbl').doc(userId).get();
      
      if (userDoc.exists) {
        _userData.value = userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }
}