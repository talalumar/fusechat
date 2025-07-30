import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fusechat/screens/login_screen.dart';
import 'package:fusechat/screens/signup_screen.dart';
import 'package:fusechat/screens/users_screen.dart';
import 'package:fusechat/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FuseChat());
}

class FuseChat extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuseChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
      routes: {
        WelcomeScreen.id : (context) => WelcomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        SignupScreen.id : (context) => SignupScreen(),
        UsersScreen.id : (context) => UsersScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, show UsersScreen
      return UsersScreen();
    } else {
      // User is NOT logged in, show WelcomeScreen
      return WelcomeScreen();
    }
  }
}