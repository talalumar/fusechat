import 'package:flutter/material.dart';
import 'package:fusechat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusechat/screens/login_screen.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(color: Color(0xFF419cd7)),
        inAsyncCall: _saving,
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(height: 45.0),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    floatingLabelStyle: TextStyle(color: Color(0xFF419cd7)),
                    border: OutlineInputBorder(), // label when focused
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF419cd7),
                        width: 2,
                      ), // border when focused
                    ),
                  ),
                ),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    floatingLabelStyle: TextStyle(color: Color(0xFF419cd7)),
                    border: OutlineInputBorder(), // label when focused
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF419cd7),
                        width: 2,
                      ), // border when focused
                    ),
                  ),
                ),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ),
              SizedBox(height: 20.0),
              RoundedButton(
                color: Color(0xFF419cd7),
                text: 'Sign Up',
                onpressed: () async {
                  setState(() {
                    _saving = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    User? user = newUser.user;
                    if (user != null && !user.emailVerified) {
                      await user.sendEmailVerification();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Verification email sent! Please verify your email before logging in.',
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Colors.white,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: 6,
                        ),
                      );

                      await _auth.signOut();
                      Navigator.pushNamed(context, LoginScreen.id);

                      // Navigator.pushNamed(context, UsersScreen.id);
                    }
                  } catch (e) {
                    print('Signup Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Signup failed. Try again.',
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 6,
                      ),
                    );
                  } finally {
                    setState(() {
                      _saving = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
