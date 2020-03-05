
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/like.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  StorageReference _storageReference;

  String _uid;

  //create user object based on firebase user
  User _userFromFirebaseUser(FirebaseUser user){
    return user != null ? User(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
    //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  //get the current user connected
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser = await _auth.currentUser();
    print("Fetching user ID: ${currentUser.uid}");
    _uid = currentUser.uid;
    return currentUser;
  }

  //sign in anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //sign in email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.message);
      print(e.toString());
      switch(e.message) {
        case 'The password is invalid or the user does not have a password.': return 1; break;
        case 'The email address is badly formatted.': return 2; break;
        case 'There is no user record corresponding to this identifier. The user may have been deleted.': return 3; break;
        default: return -1;
      }
    }
  }

  //register email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.message);
      switch(e.message) {
        case 'The email address is badly formatted.': return 1; break;
        case 'The email address is already in use by another account.': return 2; break;
        default: return null;
      }
      //The email address is badly formatted. (1)
      //The email address is already in use by another account. (2)
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //upload image to storage
  Future<String> uploadImageToStorage(File imageFile) async {
    _storageReference = FirebaseStorage.instance.ref().child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  //add photo to database for current user
  Future<void> addPhotoToDb(String imageUrl) {
    CollectionReference _collectionRef = _firestore.collection("users").document("${_uid}").collection("photos");
    print("IMAGE URL: ${imageUrl}");

    Map<String, dynamic> map = {
      "imageUrl": imageUrl
    };
    return _collectionRef.add(map);
  }

  //retrieve photo for current user
  Future<List<DocumentSnapshot>> retreiveUserPhotos(String userId) async {
    QuerySnapshot querySnapshot = await _firestore.collection("users").document(userId).collection("photos").getDocuments();
    return querySnapshot.documents;
  }

  Future<void> addLikeToPost(User curUser, Post likedPost, String postId){
    CollectionReference _ref = userCollection.document(likedPost.userId).collection("posts").document("$postid").collection("likes");
    //Will construct like.
    Like like = Like(displayName: curUser.displayName, profilePictureUrl: curUser.profilePictureUrl, uid: curUser.uid);
    //convert Like to map.
    Map map = like.toMap()
    _ref.document(curUser.uid).setData(map);
   
    //update post's number of likes.
    int numLike = int.parse(likedPost.numberOfLikes);
    numLike++;
    likedPost.numberOfLikes = numLike;
    return _ref.parent.setData(likedPost.toMap(likedPost));
  }
  Future<void> deleteLikeFromPost(User curUser, Post likedPost, String postId){
    CollectionReference _ref = userCollection.document(likedPost.userId).collection("posts").document("$postid").collection("likes");
    _ref.document(curUser.uid).delete();
    
    //update post's number of likes.
    int numLike = int.parse(likedPost.numberOfLikes);
    numLike--;
    likedPost.numberOfLikes = numLike;
    return _ref.parent.setData(likedPost.toMap(likedPost));
  }
  
}
