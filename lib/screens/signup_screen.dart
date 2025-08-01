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
                    child:
                      Image.asset('images/logo.png'),
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
                onChanged: (value){
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
                onChanged: (value){
                  password = value;
                },
              ),
              SizedBox(height: 20.0),
              RoundedButton(
                color: Colors.blueAccent,
                text: 'Sign Up',
                onpressed: () async{
                  setState(() {
                    _saving = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    User? user = newUser.user;
                    if (user != null && !user.emailVerified) {
                      await user.sendEmailVerification();

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Verification email sent! Please verify your email before logging in.'),
                      ));

                      await _auth.signOut();
                      Navigator.pushNamed(context, LoginScreen.id);

                      // Navigator.pushNamed(context, UsersScreen.id);
                    }
                  }catch (e) {
                    print('Signup Error: $e');
                     ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Signup failed. Try again.')),
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
