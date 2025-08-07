import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fusechat/screens/login_screen.dart';
import 'package:fusechat/screens/signup_screen.dart';
import 'package:fusechat/screens/users_screen.dart';
import 'package:fusechat/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusechat/services/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fusechat/components/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showNotification(message);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Offload non-critical setup
  Future.microtask(() async {
    await NotificationService.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  });

  runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
    child: FuseChat(),
  ));
}

class FuseChat extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'FuseChat',

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF419cd7),
        scaffoldBackgroundColor: Colors.white, // 👈 Background white
        cardColor: Colors.white, // 👈 Cards white
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 👈 AppBar white
          iconTheme: IconThemeData(color: Colors.black), // 👈 AppBar icon black
          titleTextStyle: TextStyle(
            color: Color(0xFF419cd7), // 👈 AppBar title blue
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[100]),
          bodyMedium: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.grey[900]),
        ),

      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // primarySwatch: Colors.blue,
        primaryColor: Color(0x99419cd7),
        scaffoldBackgroundColor: Colors.black54,
        cardColor: Color(0xFF1E1E1E), // 👈 makes cards dark
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF121212),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF121212)),
          bodyMedium: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
      ),

      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
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