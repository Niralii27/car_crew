import 'package:car_crew/screens/loginpage.dart';
import 'package:car_crew/screens/registration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _registrationState();
}

class _registrationState extends State<Registration> {
  var _isvisible = false;

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
                        onPressed: () {
                          // Navigate to the next screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => loginpage()),
                          );
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
