import 'package:car_crew/controller/snackbar_controller.dart';
import 'package:car_crew/controller/user_auth.dart';
import 'package:car_crew/screens/admin_dashboard.dart';
import 'package:car_crew/screens/admin_home.dart';
import 'package:car_crew/screens/forgotPassword.dart';
import 'package:car_crew/screens/home.dart';
import 'package:car_crew/screens/registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  var _isvisible = false;
  final Snackbar _snackbar = Snackbar();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: deviceHeight * 0.35,
              child: FittedBox(
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
              ),
            ),
            Container(
              height: deviceHeight * 0.7,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: LayoutBuilder(builder: (ctx, Constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: deviceWidth * 0.04,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 34,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Constraints.maxHeight * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: deviceWidth * 0.04),
                      child: Text(
                        'Enter your Email and Password',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Constraints.maxHeight * 0.05,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: deviceWidth * 0.02, top: deviceHeight * 0.01),
                      child: Container(
                        height: Constraints.maxHeight * 0.09,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 150, 203, 246)
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.email, color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Constraints.maxHeight * 0.05,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: deviceWidth * 0.02),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 150, 203, 246)
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: Constraints.maxHeight * 0.09,
                        child: Center(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _isvisible,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.blue),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isvisible = !_isvisible;
                                  });
                                },
                                icon: Icon(_isvisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotpasswordPage()));
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Constraints.maxHeight * 0.05,
                    ),
                    Container(
                      height: Constraints.maxHeight * 0.09,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // // Navigate to Registration page
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => Homepage()),
                          // );
                          //////////////////////////////////////////////////////////////////////
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            _snackbar.showCustomSnackBar(
                              context: context,
                              message: "Please enter both email and password.",
                              isSuccess: false,
                            );
                            return;
                          }

                          try {
                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);

                            if (credential.user != null) {
                              print("✅ Login successful");
                              final userId = credential.user!.uid;

                              //Get.to(() => Homepage());
                              if (email == "admin7@gmail.com" &&
                                  password == "Admin@2727") {
                                Get.to(() => AdminHomepage());
                              } else {
                                Get.to(() => Homepage(),
                                    arguments: {'userId': userId});
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            print(
                                "🔥 FirebaseAuth Error: ${e.code} - ${e.message}");

                            String msg = "Something went wrong!";
                            if (e.code == 'user-not-found') {
                              msg = "No user found with this email.";
                            } else if (e.code == 'wrong-password') {
                              msg = "Incorrect password.";
                            } else if (e.code == 'invalid-credential') {
                              msg = "Invalid login credentials.";
                            } else if (e.code == 'invalid-email') {
                              msg = "Invalid email format.";
                            }

                            _snackbar.showCustomSnackBar(
                              context: context,
                              message: msg,
                              isSuccess: false,
                            );
                          }
                        },
                        child: Text(
                          'Login Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: GestureDetector(
                      onTap: () async {
                        try {
                          // Attempt to sign in with Google
                          final user = await UserController.loginWithGoogle();

                          if (user != null) {
                            final email = user.email;

                            // Check if this user exists in Firestore
                            final querySnapshot = await FirebaseFirestore
                                .instance
                                .collection('UsersTbl')
                                .where('UserEmail', isEqualTo: email)
                                .limit(1)
                                .get();

                            if (querySnapshot.docs.isNotEmpty) {
                              // User exists in Firestore - direct to dashboard
                              print('✅ User is registered → Go to dashboard');

                              final userId = FirebaseAuth.instance.currentUser
                                  ?.uid; // pass the userid 

                              Get.to(() => Homepage(),
                                  arguments: {'userId': userId});
                            } else {
                              // User doesn't exist in Firestore - sign them out and ask to register
                              print(
                                  '❌ User is not registered → Go to register');
                              _snackbar.showCustomSnackBar(
                                context: context,
                                message:
                                    "Please register first before signing in with Google.",
                                isSuccess: false,
                              );

                              // Sign out from Firebase and Google
                              await FirebaseAuth.instance.signOut();
                              await GoogleSignIn().signOut();
                            }
                          }
                        } on FirebaseAuthException catch (error) {
                          print('🔥 GoogleSignIn Error: ${error.message}');
                          _snackbar.showCustomSnackBar(
                            context: context,
                            message:
                                "Failed to sign in with Google: ${error.message}",
                            isSuccess: false,
                          );
                        } catch (e) {
                          print('❌ Error: $e');
                          _snackbar.showCustomSnackBar(
                            context: context,
                            message: "Something went wrong with Google sign-in",
                            isSuccess: false,
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/googleLogo.png",
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Login with Google',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(
                      height: Constraints.maxHeight * 0.05,
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                            text: 'Don\'t have an account ?',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: ' Sign up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Registration()),
                                    );
                                  },
                              )
                            ]),
                      ),
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      )),
    );
  }
}
