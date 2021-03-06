import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegramchatapp/Models/user.dart';
import 'package:telegramchatapp/Pages/ChattingPage.dart';
import 'package:telegramchatapp/main.dart';
import 'package:telegramchatapp/services/database.dart';

import 'package:telegramchatapp/Pages/AccountSettingsPage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  final String currentUserId;

  HomeScreenState({Key key, this.currentUserId});

  Future logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()), (route) => false);
  }

  homePageHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.lightBlue,
      title: Container(
        margin: EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          decoration: InputDecoration(
              hintText: "search user",
              hintStyle: TextStyle(color: Colors.white, fontSize: 20),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              filled: true,
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                onPressed: emptyTextFormField,
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              )),
          onFieldSubmitted: controlSearching,
          style: TextStyle(fontSize: 20, color: Colors.white),
          controller: searchController,
        ),
      ), //remove the back button
    );
  }

  controlSearching(String userName) {
    print("field submitted");
    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection("chatAppUsers")
        .where("nickname", isGreaterThanOrEqualTo: userName)
        .getDocuments();

    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }

  emptyTextFormField() {
    searchController.clear();
  }

  displayNoSearchResultScreen() {
    print("no screen");
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group,
              color: Colors.lightBlueAccent,
              size: 200,
            ),
            Text("Search Users",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent))
          ],
        ),
      ),
    );
  }

  displayUserFoundScreen() {
    print("display found screen");
    return FutureBuilder(
        future: futureSearchResults,
        builder: (context, dataSnapShot) {
          if (!dataSnapShot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchUserResult = [];
          dataSnapShot.data.documents.forEach((document) {
            User eachUser = User.fromDocument(document);
            UserResult userResult = UserResult(eachUser);
            if (currentUserId != document["id"]) {
              searchUserResult.add(userResult);
            }
          });
          return ListView(
            children: searchUserResult,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
        appBar: homePageHeader(),
        body: futureSearchResults == null
            ? displayNoSearchResultScreen()
            : displayUserFoundScreen());
    // return
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    print("build user result");
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Joined : " +
                      DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(eachUser.createdAt))),
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                recieverId: eachUser.id,
                recieverAvatar: eachUser.photoUrl,
                recieverName: eachUser.nickname)));
  }
}
