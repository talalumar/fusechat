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
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(height: 10.0),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(height: 20.0),
              RoundedButton(
                color: Colors.lightBlueAccent,
                text: 'Log In',
                onpressed: () async {
                  setState(() {
                    _saving = true;
                  });
                  try {
                    final userCredential = await _auth.signInWithEmailAndPassword(
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
                            content: Text(
                              'Please verify your email before logging in. Check your inbox.',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    print('Login Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login failed. Please try again.'),
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
