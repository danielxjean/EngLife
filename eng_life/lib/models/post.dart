import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  String userId; //uid of the user making the post
  String postPhotoUrl; //imageUrl of the photo in the post
  String postPhotoRef;
  String caption; //post caption
  String displayName; //name of user posting
  String userProfilePictureUrl; //imageUrl of user's profile picture
  String numberOfLikes;
  Timestamp timestamp;

  Post({this.userId, this.postPhotoUrl, this.postPhotoRef, this.caption, this.displayName, this.userProfilePictureUrl, this.numberOfLikes, this.timestamp});

  //return a map of the object post
  Map<String, dynamic> toMap(Post post) {
    Map<String, dynamic> map = {
      'userId': post.userId,
      'postPhotoUrl': post.postPhotoUrl,
      'postPhotoRef' : post.postPhotoRef,
      'caption' : post.caption,
      'displayName' : post.displayName,
      'userProfilePictureUrl' : post.userProfilePictureUrl,
      'numberOfLikes' : post.numberOfLikes,
      'timestamp' : post.timestamp
    };
    return map;
  }

  //initialize variables from input map
  Post.mapToPost(Map<String, dynamic> map) {
    this.userId = map['userId'];
    this.postPhotoUrl = map['postPhotoUrl'];
    this.postPhotoRef = map['postPhotoRef'];
    this.caption = map['caption'];
    this.displayName = map['displayName'];
    this.userProfilePictureUrl = map['userProfilePictureUrl'];
    this.numberOfLikes = map['numberOfLikes'];
    this.timestamp = map['timestamp'];
  }

}
