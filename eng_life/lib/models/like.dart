import 'package:cloud_firestore/cloud_firestore.dart';

class Like {

  String displayName;
  String profilePictureUrl;
  String uid;
  FieldValue timeStamp;

  Like({this.displayName, this.profilePictureUrl, this.uid, this.timeStamp});

  Map toMap([Like like]) {
    Like info = like ?? this;
    var data = Map<String, dynamic>();
    data['displayName'] = info.displayName;
    data['profilePictureUrl'] = info.profilePictureUrl;
    data['uid'] = info.uid;
    data['timestamp'] = info.timeStamp.toString();
    return data;
  }

  Like.fromMap(Map<String, dynamic> mapData) {
    this.displayName = mapData['displayName'];
    this.profilePictureUrl = mapData['profilePictureUrl'];
    this.uid = mapData['uid'];
    this.timeStamp = mapData['timestamp'];
  }

}
