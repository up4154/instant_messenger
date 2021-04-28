import 'package:flutter/material.dart';
import 'package:instant_messenger/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messenger'),),
      body: Center(
        child: GestureDetector(
          onTap: (){
            AuthMethods().signInWithGoogle(context);
          },
          child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Color(0xffDB4437),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
          child: Text("Sign In With Google",style: TextStyle(fontSize: 16,color: Colors.white),),

      ),
        ),),
    );
  }
}
