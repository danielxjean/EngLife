import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  String userId; //uid of the user making the post
  String postPhotoUrl; //imageUrl of the photo in the post
  String caption; //post caption
  FieldValue timeStamp; //timestamp of post creation
  String userName; //name of user posting
  String userProfilePictureUrl; //imageUrl of user's profile picture

  Post({this.userId, this.postPhotoUrl, this.caption, this.timeStamp, this.userName, this.userProfilePictureUrl});

  //return a map of the object post
  Map<String, dynamic> toMap(Post post) {
    Map<String, dynamic> map = {
      'userId': post.userId,
      'photoUrl': post.postPhotoUrl,
      'caption' : post.caption,
      'timestamp' : post.timeStamp,
      'userName' : post.userName,
      'profileUrl' : post.userProfilePictureUrl
    };
    return map;
  }

  //initialize variables from input map

}