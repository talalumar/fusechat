import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fusechat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusechat/screens/users_screen.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool _saving = false;

  Future<void> saveFcmTokenToFirestore(String uid) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
      });
    }
  }

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
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    prefixIcon: Icon(Icons.email, color: Colors.grey[700],),
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
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    prefixIcon: Icon(Icons.lock, color: Colors.grey[700],),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ),
              SizedBox(height: 20.0),
              RoundedButton(
                color: Color(0xFF419cd7),
                text: 'Log In',
                onpressed: () async {
                  setState(() {
                    _saving = true;
                  });
                  try {
                    final userCredential = await _auth
                        .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                    User? user = userCredential.user;
                    if (user != null) {
                      await user.reload(); // Refresh user data
                      user = FirebaseAuth.instance.currentUser;

                      if (user!.emailVerified) {
                        // Check if user exists in Firestore
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        if (!userDoc.exists) {
                          // Save user to Firestore only after verification
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                                'uid': user.uid,
                                'email': user.email,
                                'name': user.email!.split('@')[0],
                                'createdAt': Timestamp.now(),
                              });
                        }
                        // Save FCM token
                        await saveFcmTokenToFirestore(user.uid);

                        // Navigate to UsersScreen
                        Navigator.pushReplacementNamed(context, UsersScreen.id);
                      } else {
                        // Email not verified
                        await _auth.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please verify your email before logging in. Check your inbox.',
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
                      }
                    }
                  } catch (e) {
                    print('Login Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Login failed. Please try again.',
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
