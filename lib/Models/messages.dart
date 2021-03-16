import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  final String content;
  final String idFrom;
  final String idTo;
  final String timeStamp;
  final int type;

  Messages({
    this.content,
    this.idFrom,
    this.idTo,
    this.timeStamp,
    this.type,
  });

  factory Messages.fromDocument(DocumentSnapshot doc) {
    return Messages(
        content: doc['content'],
        idFrom: doc['idFrom'],
        idTo: doc['idTo'],
        timeStamp: doc['timeStamp'],
        type: doc['type']);
  }
}
