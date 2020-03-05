import 'package:cloud_firestore/cloud_firestore.dart';


class Comment {

  String displayName = "";
  String profilePictureUrl = "";
  String comment = "";
  String uid = "";
  FieldValue timeStamp;

  Comment({this.displayName, this.profilePictureUrl, this.comment, this.uid, this.timeStamp});

  Map toMap(Comment comment) {

    var data = Map<String, dynamic>();
    data['displayName'] = comment.displayName;
    data['profilePictureUrl'] = comment.profilePictureUrl;
    data['comment'] = comment.comment;
    data['uid'] = comment.uid;
    data['timeStamp'] = comment.timeStamp;
    return data;
  }

  Comment.fromMap(Map<String, dynamic> mapData) {
    this.displayName = mapData['displayName'];
    this.profilePictureUrl = mapData['profilePictureUrl'];
    this.comment = mapData['comment'];
    this.uid = mapData['uid'];
    this.timeStamp = mapData['timeStamp'];
  }

}