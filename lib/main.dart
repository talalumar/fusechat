import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fusechat/screens/chart_screen.dart';
import 'package:fusechat/screens/login_screen.dart';
import 'package:fusechat/screens/signup_screen.dart';
import 'package:fusechat/screens/welcome_screen.dart';// (create later)

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
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id : (context) => WelcomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        SignupScreen.id : (context) => SignupScreen(),
        ChartScreen.id : (context) => ChartScreen(),
      },// Start with login
    );
  }
}
