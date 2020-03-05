import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/models/like.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';


class DatabaseService {

  String uid;

  DatabaseService({this.uid});

  //collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final _authService = AuthService();

  Future<void> addPhotoToDb(String imageUrl){
    CollectionReference _ref = userCollection.document(this.uid).collection("photos");
    Map map = {'imageUrl': imageUrl};
    return _ref.add(map);
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    StorageReference _storageReference = FirebaseStorage.instance.ref().child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  void setUid(String uid){
    this.uid = uid;
  }

  Future<void> addLikeToPost(User curUser, Post likedPost, String postId){
    CollectionReference _ref = userCollection.document(likedPost.userId).collection("posts").document("$postid").collection("likes");
    //Will construct like.
    Like like = Like(displayName: curUser.displayName, profilePictureUrl: curUser.profilePictureUrl, uid: curUser.uid);
    //convert Like to map.
    Map map = like.toMap()
    return _ref.document(curUser.uid).setData(map);
  }
  Future<void> deleteLikeFromPost(User curUser, Post likedPost, String postId){
    CollectionReference _ref = userCollection.document(likedPost.userId).collection("posts").document("$postid").collection("likes");
    return _ref.document(curUser.uid).delete();
  }
  
}
