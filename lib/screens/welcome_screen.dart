import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'package:fusechat/components/rounded_button.dart';


class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  height: 60.0,
                  child: Image(image: AssetImage('images/logo.png')),
                ),
                SizedBox(width: 10.0,),
                Text('Fuse Chat',
                style: TextStyle(
                  fontSize: 45.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
                )
              ],
            ),
            SizedBox(height: 48.0,),
            RoundedButton(
              color: Colors.lightBlueAccent,
              text: 'Log In',
              onpressed: (){
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            SizedBox(height: 20.0,),
            RoundedButton(
              color: Colors.blueAccent,
              text: 'Sign Up',
              onpressed: (){
                Navigator.pushNamed(context, SignupScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

