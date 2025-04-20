import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user in both Authentication and Firestore
  Future<User?> registerUser(String name, String email, String password) async {
    try {
      // create user in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // If authentication creation is successful, add user to Firestore
      if (userCredential.user != null) {
        await _firestore
            .collection('UsersTbl')
            .doc(userCredential.user!.uid)
            .set({
          'UserName': name,
          'UserEmail': email,
          'UserImage': null,
          // 'UserPassword': password, //for security reasons
          //'UserRole': role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("✅ User added to Authentication and Firestore!");
        return userCredential.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print("❌ Authentication Error: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("❌ Error: $e");
      throw e;
    }
  }
//for the forgot password
 Future<String?> sendPasswordResetEmail(String email) async {
     try {
       await _auth.sendPasswordResetEmail(email: email);
       return null; // null means success
     } on FirebaseAuthException catch (e) {
       if (e.code == 'user-not-found') {
         return 'No user found for that email.';
       } else if (e.code == 'invalid-email') {
         return 'Invalid email format.';
       } else {
         return 'Something went wrong. Please try again.';
       }
     } catch (e) {
       return 'An unexpected error occurred.';
     }
   }
  // Keep the original method for backward compatibility if needed
  Future<void> addUser(
      String name, String email, String password, String role) async {
    try {
      await _firestore.collection('UsersTbl').add({
        'UserName': name,
        'UserEmail': email,
        'UserPassword':
            password, // Note: Storing passwords in Firestore is a security risk
        'UserRole': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("✅ User added to Firestore collection!");
    } catch (e) {
      print("❌ Error: $e");
    }
  }
}
