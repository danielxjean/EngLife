
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

  String _displayName = "Default";

  User _currentUser;

  //create user object based on firebase user
  User _userFromFirebaseUser(FirebaseUser user){
    if (user == null) {
      print("DEBUG*********USER IS NULL");
      return null;
    }
    else {
      print("DEBUG*********USER NOY NULL");
      return  User(
          bio: "",
          uid: user.uid,
          email: user.email,
          displayName: _displayName,
          educationMajor: 'Default',
          numOfPosts: '0',
          numOfFollowers: '0',
          numOfFollowing: '0',
          profilePictureUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png",
          username: "Default"); //username input needs to be added to register form, must be unique
    }
  }

  //auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
    //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  //get the current user connected
  Future<User> getCurrentUser() async {
    print("Fetching current user...");
    FirebaseUser currentUser = await _auth.currentUser();

    //convert firebaseuser into our user model

    //first get user information from database
    DocumentSnapshot _userInfo = await _firestore.collection("users").document(currentUser.uid).get();
    //create new user from user info
    User _currentUser = User.mapToUser(_userInfo.data);

    this._currentUser = _currentUser;

    return _currentUser;
  }

  Future<User> getUser(String userId) async {

    //first get user information from database
    DocumentSnapshot _userInfo = await _firestore.collection("users").document(userId).get();
    //create new user from user info
    User _currentUser = User.mapToUser(_userInfo.data);

    this._currentUser = _currentUser;

    return _currentUser;
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
  Future registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      print("PRINTING FROM REGISTER****: " + firebaseUser.toString());

      this._displayName = displayName;

      createNewUserInDatabase(_userFromFirebaseUser(firebaseUser));
      return _userFromFirebaseUser(firebaseUser);
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

  Future<void> createNewUserInDatabase(User user) {
    Map<String, dynamic> userMap = user.userToMap(user);

    print(userMap.toString());

    return _firestore.collection("users").document(user.uid).setData(userMap);
  }

  //upload image to storage
  Future<String> uploadImageToStorage(File imageFile) async {
    _storageReference = FirebaseStorage.instance.ref().child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  //add photo to database for current user
  Future<void> addPhostToDb(String imageUrl, String caption, User user) {
    CollectionReference _collectionRef = _firestore.collection("users").document("${user.uid}").collection("posts");
    print("IMAGE URL: ${imageUrl}");

    Post post = Post(
        userId: user.uid,
        postPhotoUrl: imageUrl,
        caption: caption,
        displayName: user.displayName,
        userProfilePictureUrl:
        user.profilePictureUrl,
        numberOfLikes: "0");

    //add post to db
    _collectionRef.add(post.toMap(post));

    //increment number of posts in user
    int numOfPosts = int.parse(user.numOfPosts);
    numOfPosts++;
    user.numOfPosts = "${numOfPosts}";

    //update user information in db
    return _firestore.collection("users").document("${user.uid}").setData(user.userToMap(user));
  }

  //retrieve photo for current user
  Future<List<DocumentSnapshot>> retreiveUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore.collection("users").document(userId).collection("posts").getDocuments();
    return querySnapshot.documents;
  }
  
  //curUser will follow user2.
  Future<void> addUserFollow(User curUser, User user2){
    _addUserAsFollowerOf(curUser.uid, user2);
    _addUserAsFollowing(curUser, user2.uid);
  }
  
  Future<void> _addUserAsFollowerOf(String curUserid, User user2){
	String uid2 = user2.uid;
    CollectionReference _ref = _firestore.collection("users").document(uid2).collection("followers");
    Map<String, dynamic> map = {'userid': curUserid};
    _ref.document(curUserid).setData(map);
    
	//update number of followers
    int numFollowers = int.parse(user2.numOfFollowers);
    numFollowers++;
    user2.numOfFollowers = "$numFollowers";
    return _firestore.collection("users").document(uid2).setData(user2.userToMap(user2));
  }
  
  Future<void> _addUserAsFollowing(User curUser, String uid2){
	String curUserid = curUser.uid;
    CollectionReference _ref = _firestore.collection("users").document(curUserid).collection("following");
    Map<String, dynamic> map = {'userid': uid2};
    _ref.document(uid2).setData(map);

    int numFollowing = int.parse(curUser.numOfFollowing);
    numFollowing++;
    curUser.numOfFollowing = "$numFollowing";
    return _firestore.collection("users").document(curUserid).setData(curUser.userToMap(curUser));
  }






  //curUser will unfollow user2.
  Future<void> removeUserFollow(User curUser, User user2){
    _removeUserAsFollowerOf(curUser.uid, user2);
    _removeUserAsFollowing(curUser, user2.uid);
  }




  Future<void> _removeUserAsFollowerOf(String curUserid, User user2){
    //removes the curUserId document from the followers collection of user2

    String uid2 = user2.uid;
    CollectionReference _ref = _firestore.collection("users").document(uid2).collection("followers");
    _ref.document(curUserid).delete();

    //update number of followers
    int numFollowers = int.parse(user2.numOfFollowers);
    numFollowers--;
    user2.numOfFollowers = "$numFollowers";
    return _firestore.collection("users").document(uid2).setData(user2.userToMap(user2));
  }




  Future<void> _removeUserAsFollowing(User curUser, String uid2){
    //removes the uid2 document from the following collection of curUser

    String curUserid = curUser.uid;
    CollectionReference _ref = _firestore.collection("users").document(curUserid).collection("following");
    _ref.document(uid2).delete();

    //update number of following
    int numFollowing = int.parse(curUser.numOfFollowing);
    numFollowing--;
    curUser.numOfFollowing = "$numFollowing";
    return _firestore.collection("users").document(curUserid).setData(curUser.userToMap(curUser));
  }






  Future<void> addLikeToPost(User curUser, Post likedPost, String postId){
    CollectionReference _ref = _firestore.collection("users").document(likedPost.userId).collection("posts").document("$postId").collection("likes");
    //Will construct like.
    Like like = Like(displayName: curUser.displayName, profilePictureUrl: curUser.profilePictureUrl, uid: curUser.uid);
    //convert Like to map.
    Map map = like.toMap();
    _ref.document(curUser.uid).setData(map);
   
    //update post's number of likes.
    int numLike = int.parse(likedPost.numberOfLikes);
    numLike++;
    likedPost.numberOfLikes = "$numLike";
    return _firestore.collection("users").document(likedPost.userId).collection("posts").document(postId).setData(likedPost.toMap(likedPost));
  }
  
  Future<void> deleteLikeFromPost(User curUser, Post likedPost, String postId){
    CollectionReference _ref = _firestore.collection("users").document(likedPost.userId).collection("posts").document("$postId").collection("likes");
    _ref.document(curUser.uid).delete();
    
    //update post's number of likes.
    int numLike = int.parse(likedPost.numberOfLikes);
    numLike--;
    likedPost.numberOfLikes = "$numLike";
    return _firestore.collection("users").document(likedPost.userId).collection("posts").document(postId).setData(likedPost.toMap(likedPost));
  }

  Future<List<DocumentSnapshot>> retreiveUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection("users").getDocuments();
    return querySnapshot.documents;
  }

  Future<bool> checkIfCurrentUserLiked(String userId, DocumentReference documentReference) async {
    DocumentSnapshot documentSnapshot = await documentReference.collection("likes").document(userId).get();
    return documentSnapshot.exists;
  }

  Future<bool> checkIfCurrentUserIsFollowing(String userId, String currentUserId) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection("users").document(userId).collection("followers").document(currentUserId).get();
    return documentSnapshot.exists;
  }

  Future<DocumentSnapshot> refreshSnapshotInfo(DocumentSnapshot documentSnapshot) async {
    DocumentSnapshot snapshot = await documentSnapshot.reference.get();
    return snapshot;
  }

}
