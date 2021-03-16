import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telegramchatapp/Models/user.dart';

class Database {
  final Firestore _firestore = Firestore.instance;
  controlSearching(String userName) {
    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection("chatAppUsers")
        .where("nickname", isGreaterThanOrEqualTo: userName)
        .getDocuments();
  }
}
