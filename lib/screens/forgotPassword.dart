import 'package:car_crew/screens/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:car_crew/screens/registration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class ForgotpasswordPage extends StatefulWidget {
  const ForgotpasswordPage({super.key});

  @override
  State<ForgotpasswordPage> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<ForgotpasswordPage> {
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
            Padding(
              padding: EdgeInsets.only(top: deviceHeight * 0.2),
              child: Container(
                height: deviceHeight * 0.15,
                width: deviceWidth * 0.4, // optional: adjust width as needed
                child: Image.asset(
                  'assets/password.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              height: deviceHeight * 0.05,
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
                      child: Center(
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Constraints.maxHeight * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: deviceWidth * 0.04),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: deviceWidth * 0.02,
                            right: deviceWidth * 0.02),
                        child: Center(
                          child: Text(
                            'Provide your account\'s email for which you\n       want to reset your Password!',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
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
                    Container(
                      height: Constraints.maxHeight * 0.09,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Registration page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => loginpage()),
                          );
                        },
                        child: Text(
                          'Reset Password',
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
                      height: Constraints.maxHeight * 0.03,
                    ),
                    Container(
                      height: Constraints.maxHeight * 0.09,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Registration page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => loginpage()),
                          );
                        },
                        child: Text(
                          'Back',
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
