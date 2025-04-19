import 'package:car_crew/controller/snackbar_controller.dart';
import 'package:car_crew/screens/loginpage.dart';
import 'package:car_crew/screens/registration.dart';
import 'package:car_crew/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _registrationState();
}

class _registrationState extends State<Registration> {
  var _isvisible = false;
  final Snackbar _snackbar = Snackbar();

  final FirebaseServices firebaseServices = FirebaseServices();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // String? selectedRole;

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
              height: deviceHeight * 0.30,
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
                        'Sign Up',
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
                        'Enter your Name, Email and Password',
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
                        child: Container(
                          height: Constraints.maxHeight * 0.08,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 150, 203, 246)
                                .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Name',
                                prefixIcon:
                                    Icon(Icons.person, color: Colors.blue),
                              ),
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
                        height: Constraints.maxHeight * 0.09,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 150, 203, 246)
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: TextField(
                            controller: emailController,
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
                            controller: passwordController,
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
                            controller: confirmPasswordController,
                            obscureText: _isvisible,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Confirm Password',
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
                    SizedBox(
                      height: Constraints.maxHeight * 0.05,
                    ),
                    Container(
                      height: Constraints.maxHeight * 0.09,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // final name = nameController.text.trim();
                          // final email = emailController.text.trim();
                          // final password = passwordController.text.trim();
                          // final confirmPassword =
                          //     confirmPasswordController.text.trim();

                          // if (name.isEmpty ||
                          //     email.isEmpty ||
                          //     password.isEmpty ||
                          //     confirmPassword.isEmpty) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text('⚠️ Please fill all the fields'),
                          //       backgroundColor: Colors.redAccent,
                          //     ),
                          //   );
                          //   return;
                          // }

                          // if (password != confirmPassword) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text('⚠️ Passwords do not match'),
                          //       backgroundColor: Colors.redAccent,
                          //     ),
                          //   );
                          //   return;
                          // }

                          // try {
                          //   // Register user with Firebase Auth
                          //   final credential = await FirebaseAuth.instance
                          //       .createUserWithEmailAndPassword(
                          //     email: email,
                          //     password: password,
                          //   );

                          //   // Get user ID and store additional info in Realtime Database
                          //   final uid = credential.user!.uid;
                          //   final ref = FirebaseDatabase.instance
                          //       .ref()
                          //       .child('users')
                          //       .child(uid);
                          //   await ref.set({
                          //     'name': name,
                          //     'email': email,
                          //   });

                          //   // Success message
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content:
                          //           Text('✅ Sign Up Successful! Please login.'),
                          //       backgroundColor: Colors.green,
                          //     ),
                          //   );

                          //   // Navigate to login page
                          //   Future.delayed(Duration(seconds: 2), () {
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(builder: (_) => loginpage()),
                          //     );
                          //   });
                          // } on FirebaseAuthException catch (e) {
                          //   String errorMessage = '⚠️ Something went wrong';

                          //   if (e.code == 'email-already-in-use') {
                          //     errorMessage =
                          //         '⚠️ Email is already registered. Please login.';
                          //   } else if (e.code == 'invalid-email') {
                          //     errorMessage = '⚠️ Invalid email format.';
                          //   } else if (e.code == 'weak-password') {
                          //     errorMessage =
                          //         '⚠️ Password should be at least 6 characters.';
                          //   }

                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text(errorMessage),
                          //       backgroundColor: Colors.redAccent,
                          //     ),
                          //   );
                          // } catch (e) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text(
                          //           '⚠️ Error: ${e is FirebaseAuthException ? e.message ?? e.toString() : e.toString()}'),
                          //       backgroundColor: Colors.redAccent,
                          //     ),
                          //   );
                          // }
///////////////////////////////////////////////////////////////////////////////

                          // Get.to(DashboardWithNav());
                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passwordController.text;
                          final confirmPassword =
                              confirmPasswordController.text;

                          if (name.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty ||
                                  confirmPassword.isEmpty
                              // selectedRole == null
                              ) {
                            // Get.snackbar("Error", "All fields are required");
                            _snackbar.showCustomSnackBar(
                              context: context,
                              message: "All fields are required",
                              isSuccess: false,
                            );

                            return;
                          }
                          if (password != confirmPassword) {
                            // Get.snackbar("Error", "Passwords Do Not Match");
                            _snackbar.showCustomSnackBar(
                              context: context,
                              message: "Passwords do not match",
                              isSuccess: false,
                            );

                            return;
                          }
                          try {
                            // register in both Firebase Auth and Firestore
                            final user = await firebaseServices.registerUser(
                                name, email, password);

                            if (user != null) {
                              _snackbar.showCustomSnackBar(
                                context: context,
                                message:
                                    "Registered successfully! Please Login.",
                                isSuccess: true,
                              );

                              Future.delayed(Duration(seconds: 2), () {
                                Get.to(() => loginpage());
                              });
                            }
                          } catch (e) {
                            String errorMessage = "Registration failed";
                            if (e is FirebaseAuthException) {
                              if (e.code == 'email-already-in-use') {
                                errorMessage = "Email is already registered";
                              } else if (e.code == 'weak-password') {
                                errorMessage = "Password is too weak";
                              } else if (e.code == 'invalid-email') {
                                errorMessage = "Invalid email format";
                              }
                            }

                            _snackbar.showCustomSnackBar(
                              context: context,
                              message: errorMessage,
                              isSuccess: false,
                            );
                          }
                        },
                        child: Text(
                          'Sign Up',
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
                      height: Constraints.maxHeight * 0.05,
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                            text: 'Do You have an account ?',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: ' Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => loginpage()),
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
