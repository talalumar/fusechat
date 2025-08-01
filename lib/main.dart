import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fusechat/screens/login_screen.dart';
import 'package:fusechat/screens/signup_screen.dart';
import 'package:fusechat/screens/users_screen.dart';
import 'package:fusechat/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusechat/services/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showNotification(message);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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