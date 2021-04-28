import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instant_messenger/services/auth.dart';
import 'package:instant_messenger/views/home.dart';
import 'package:instant_messenger/views/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context,AsyncSnapshot<dynamic> snapshot){
          if(snapshot.hasData){
            return Home();
          }
          else{
            return SignIn();
          }
        },
      ),
    );
  }
}

