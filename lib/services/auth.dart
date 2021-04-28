import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:instant_messenger/helper%20function/sharepref_helper.dart';
import 'package:instant_messenger/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

 class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

    getCurrentUser() async{
    return auth.currentUser;
  }
  signInWithGoogle(BuildContext context) async{
     final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
     final GoogleSignIn _googleSignIn=GoogleSignIn();
     final GoogleSignInAccount googleSignInAccount =
       await _googleSignIn.signIn();
     final GoogleSignInAuthentication googleSignInAuthentication =
         await googleSignInAccount.authentication;
     final AuthCredential credential =GoogleAuthProvider.credential(
       idToken: googleSignInAuthentication.idToken,
       accessToken: googleSignInAuthentication.accessToken
     );
     UserCredential result = await _firebaseAuth.signInWithCredential(credential);

     User userDatails =result.user;

     if(result != null){
       SharedPreferenceHelper().saveUserEmail(userDatails.email);
       SharedPreferenceHelper().saveUserId(userDatails.uid);
       SharedPreferenceHelper().saveUserName(userDatails.email.replaceAll("@gmail.com",""));
       SharedPreferenceHelper().saveDisplayName(userDatails.displayName);
       SharedPreferenceHelper().saveUserProfileUrl(userDatails.photoURL);

       Map<String,dynamic> userInfoMap={
         "email":userDatails.email,
         "username":userDatails.email.replaceAll("@gmail.com", ""),
         "name":userDatails.displayName,
         "imgUrl":userDatails.photoURL,
       };
       DatabaseMethods().addUserInfoToDB(userDatails.uid,userInfoMap).then(
               (value) {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder:
                 (context) => Home(),
                 ));
               });
     }

  }
    Future signOut() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }
}