import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Pages/HomePage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telegramchatapp/main.dart';
import 'dart:developer';

import '../Widgets/ProgressWidget.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentuser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  isSignedIn() async {
    print("initstate");
    setState(() {
      isLoggedIn = true;
    });
    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: preferences.get('id'))));
    }
    setState(() {
      isLoading = false;
    });
  }

  Future controlSignin() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      print("user sihned In");
      // check if already sign up
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection('chatAppUsers')
          .where("id", isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documentSnapshot = resultQuery.documents;
      // save user in database
      if (documentSnapshot.length == 0) {
        Firestore.instance
            .collection("chatAppUsers")
            .document(firebaseUser.uid)
            .setData({
          "nickname": firebaseUser.displayName,
          "photoUrl": firebaseUser.photoUrl,
          "id": firebaseUser.uid,
          "aboutMe": "i m using flutter",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });
        // write data to local
        currentuser = firebaseUser;
        await preferences.setString("id", currentuser.uid);
        await preferences.setString("nickname", currentuser.displayName);
        await preferences.setString("photoUrl", currentuser.photoUrl);
      } else {
        currentuser = firebaseUser;
        await preferences.setString("id", documentSnapshot[0]['id']);
        await preferences.setString(
            "nickname", documentSnapshot[0]['nickname']);
        await preferences.setString(
            "photoUrl", documentSnapshot[0]['photoUrl']);
        await preferences.setString("aboutMe", documentSnapshot[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "login success");
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    currentUserId: firebaseUser.uid,
                  )));
    } else {
      Fluttertoast.showToast(msg: "try Again");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          )),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'FLutter',
                style: TextStyle(
                    fontFamily: "Signatra", fontSize: 90, color: Colors.white),
              ),
              GestureDetector(
                onTap: controlSignin,
                child: Container(
                  width: 260,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/google_signin_button.png'),
                          fit: BoxFit.cover)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: isLoading ? circularProgress() : Container(),
              )
            ],
          )),
    );
  }
}
