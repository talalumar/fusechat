import 'package:flutter/material.dart';
import 'package:fusechat/components/rounded_button.dart';

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100.0,
              child:
                Image.asset('images/logo.png'),
            ),
            SizedBox(height: 45.0),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
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
