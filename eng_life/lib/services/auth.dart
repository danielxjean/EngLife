import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/like.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

enum Field {
  numberOfLikes, numberOfFollowers, numberOfFollowings, numberOfPosts
}
extension FieldExtension on Field{

  String get name {
    switch(this){
      case Field.numberOfFollowers:
        return 'numOfFollowers';
      case Field.numberOfFollowings:
        return 'numOfFollowing';
      case Field.numberOfLikes:
        return 'numberOfLikes';
      case Field.numberOfPosts:
        return 'numOfPosts';
      default:
        throw Exception('Invalid Field compiled');
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  StorageReference _storageReference;

  //locks
  static final Map<String, Future<void>> _isLiking = Map();
  static final Map<String, Future<void>> _isFollowing = Map();
  static final Map<String, Future<void>> _isFollowed = Map();


  //create user object based on firebase user
  User _userFromFirebaseUser(FirebaseUser user){
    if (user == null) {
      print("DEBUG*********USER IS NULL");
      return null;
    }
    else {
      print("DEBUG*********USER NOT NULL");
      return  User(
          bio: "",
          uid: user.uid,
          email: user.email,
          displayName: 'Default',
          educationMajor: 'Default',
          numOfPosts: '0',
          numOfFollowers: '0',
          numOfFollowing: '0',
          profilePictureUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png",
          username: "Default",//username input needs to be added to register form, must be unique
          isGroup: false,
          firstLogin: true);
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

    return _currentUser;
  }

  Future<User> getUser(String userId) async {

    //first get user information from database
    DocumentSnapshot _userInfo = await _firestore.collection("users").document(userId).get();
    //create new user from user info
    User _currentUser = User.mapToUser(_userInfo.data);

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
  Future registerWithEmailAndPassword(String email, String password, [String displayName = 'Default', bool isGroup = false, bool firstLogin = true]) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      print("PRINTING FROM REGISTER****: " + firebaseUser.toString());

      User createdUser = _userFromFirebaseUser(firebaseUser);

      createdUser.displayName = displayName;
      createdUser.isGroup = isGroup;
      createdUser.firstLogin = firstLogin;

      createNewUserInDatabase(createdUser);
      return createdUser;
    } catch(e) {
      print(e.message);
      switch(e.message) {
        case 'The email address is badly formatted.': return 1; break;
        case 'The email address is already in use by another account.': return 2; break;
        default: return -1;
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
  Future<Map<String, String>> uploadImageToStorage(File imageFile) async {
    String _storageRef = '${DateTime.now().millisecondsSinceEpoch}';

    print("DEBUG AuthService: $_storageRef");

    _storageReference = FirebaseStorage.instance.ref().child(_storageRef);
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

    Map<String, String> _imageRef = {
      'storageRef' : _storageRef,
      'imageUrl' : url
    };

    return _imageRef;
  }

  //add photo to database for current user

  Future<void> addPostToDb(Map<String, String> imageData, String caption, User user) async {
    CollectionReference _collectionRef = _firestore.collection("users").document("${user.uid}").collection("posts");
    print("IMAGE URL: ${imageData['imageUrl']}");

    Post post = Post(
        userId: user.uid,
        postPhotoUrl: imageData['imageUrl'],
        postPhotoRef: imageData['storageRef'],
        caption: caption,
        displayName: user.displayName,
        userProfilePictureUrl: user.profilePictureUrl,
        numberOfLikes: "0",
        timestamp: Timestamp.now()
    );

    //add post to db and return the post document id
    DocumentReference documentReference = await _collectionRef.add(post.toMap(post));
    String postId = documentReference.documentID;

    //increment number of posts in user
    return _changeDocumentFieldValue(_collectionRef.parent(), Field.numberOfPosts.name, true);
  }

  //retrieve photo for current user
  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore.collection("users").document(userId).collection("posts").getDocuments();
    return querySnapshot.documents;
  }

  //Increments or decrements a field in the document reference.
  Future<void> _changeDocumentFieldValue(DocumentReference documentReference, String field, bool add) async{
    int newValue = int.parse((await documentReference.get())[field]);
    add ? newValue++ : newValue--;
    return await documentReference.updateData({field: '$newValue'});
  }

  //region Follower/Following
  //region Visible Follower/Following Method
  //curUser will follow user2.
  Future<void> addUserFollow(User curUser, User user2) async{
    await Future.wait([
      _userAsFollowerOf(curUser, user2, true),
      _userAsFollowing(curUser, user2, true)
    ]);
  }
  //curUser will unfollow user2.
  Future<void> removeUserFollow(User curUser, User user2) async {
    await Future.wait([
      _userAsFollowerOf(curUser, user2, false),
      _userAsFollowing(curUser, user2, false)
    ]);
  }
  //endregion

  //region Split follow/unfollow routines
  //endregion

  //region Handle synchronization
  Future<void> _userAsFollowerOf(User curUser, User user2, bool addFollow) async{
    String uid2 = user2.uid;
    //Wait
    if (_isFollowed[uid2] != null){
      await _isFollowed[uid2];
      return _userAsFollowerOf(curUser, user2, addFollow);
    }
    //Lock
    Completer completer = Completer<Null>();
    _isFollowed[uid2] = completer.future;

    //Critical Section
    addFollow ? await _addUserAsFollowerOf(curUser, user2)
        : await _removeUserAsFollowerOf(curUser.uid, user2);

    //Unlock
    completer.complete();
    _isFollowed[uid2] = null;
  }
  Future<void> _userAsFollowing(User curUser, User user2, bool addFollow) async{
    String curUserId = curUser.uid;
    //Wait
    if (_isFollowing[curUserId] != null){
      await _isFollowing[curUserId];
      return _userAsFollowing(curUser, user2, addFollow);
    }
    //Lock
    Completer completer = Completer<Null>();
    _isFollowing[curUserId] = completer.future;

    //Critical Section
    addFollow ? await _addUserAsFollowing(curUser, user2)
        : await _removeUserAsFollowing(curUser, user2.uid);

    //Unlock
    completer.complete();
    _isFollowing[curUserId] = null;
  }
  //endregion

  //region Follow/Following Methods
  Future<void> _addUserAsFollowerOf(User curUser, User user2) async{
    String uid2 = user2.uid;
    DocumentReference _ref = _firestore.collection("users").document(uid2);
    Map<String, dynamic> map = {'userid': curUser.uid, 'isGroup': curUser.isGroup};
    _ref.collection("followers").document(curUser.uid).setData(map);

	  //update number of followers
    return _changeDocumentFieldValue(_ref, Field.numberOfFollowers.name, true);
  }

  Future<void> _addUserAsFollowing(User curUser, User user2) async{
    String curUserId = curUser.uid;
    DocumentReference _ref = _firestore.collection("users").document(curUserId);
    Map<String, dynamic> map = {'userid': user2.uid, 'isGroup': user2.isGroup};
    _ref.collection("following").document(user2.uid).setData(map);

    //update number of followers
    return _changeDocumentFieldValue(_ref, Field.numberOfFollowings.name, true);
  }

  Future<void> _removeUserAsFollowerOf(String curUserId, User user2) async{
    //removes the curUserId document from the followers collection of user2
    String uid2 = user2.uid;
    DocumentReference _ref = _firestore.collection("users").document(uid2);
    _ref.collection("followers").document(curUserId).delete();

    //update number of followers
    return _changeDocumentFieldValue(_ref, Field.numberOfFollowers.name, false);
  }

  Future<void> _removeUserAsFollowing(User curUser, String uid2) async{
    //removes the uid2 document from the following collection of curUser
    String curUserId = curUser.uid;
    DocumentReference _ref = _firestore.collection("users").document(curUserId);
    _ref.collection("following").document(uid2).delete();

    //update number of following
    return _changeDocumentFieldValue(_ref, Field.numberOfFollowings.name, false);
  }
  //endregion
  //endregion

  //region Like/Dislike Post
  //Visible Like/Dislike Method + Handle Synchronization
  Future<void> likePost(User curUser, Post likedPost, String postId, bool like) async{
   //Wait
   if (_isLiking[postId] != null){
     await _isLiking[postId];
     return likePost(curUser, likedPost, postId, like);
   }
   //Lock
   Completer completer = Completer<Null>();
   _isLiking[postId] = completer.future;

   //Critical Section
    like ? await _addLikeToPost(curUser, likedPost ,postId)
        : await _deleteLikeFromPost(curUser, likedPost, postId);

   //Unlock
   completer.complete();
   _isLiking[postId] = null;
  }

  //region Like/Dislike Methods
  Future<void> _addLikeToPost(User curUser, Post likedPost, String postId) async{
    DocumentReference _ref = _firestore.collection("users").document(likedPost.userId).collection("posts").document("$postId");
    //Will construct like.
    Like like = Like(displayName: curUser.displayName, profilePictureUrl: curUser.profilePictureUrl, uid: curUser.uid);
    //convert Like to map.
    Map map = like.toMap();
    await _ref.collection("likes").document(curUser.uid).setData(map);

    //update post's number of likes.
    return _changeDocumentFieldValue(_ref, Field.numberOfLikes.name, true);
  }

  Future<void> _deleteLikeFromPost(User curUser, Post likedPost, String postId) async{
    DocumentReference _ref = _firestore.collection("users").document(likedPost.userId).collection("posts").document("$postId");
    //print('del: ${(await _ref.document(curUser.uid).get()).data}');
    await _ref.collection("likes").document(curUser.uid).delete();

    //update post's number of likes.
    return _changeDocumentFieldValue(_ref, Field.numberOfLikes.name, false);
  }
  //endregion
  //endregion

  Future<QuerySnapshot> retrieveUsers() async {
    return _firestore.collection("users").getDocuments();
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

  Future<void> updateUserFirstLogin(User user, bool firstLogin) {
    user.firstLogin = firstLogin;
    return _firestore.collection("users").document("${user.uid}").setData(user.userToMap(user));
  }

  Future<List<DocumentSnapshot>> retrieveGroups() async {
    QuerySnapshot querySnapshot = await _firestore.collection("users").where("isGroup", isEqualTo: true).getDocuments();
    return querySnapshot.documents;
  }

  Future<void> updateUserProfileInformation(User user, Map<String, String> imageData, String newDisplayName, String newBio) {
    user.displayName = newDisplayName;
    user.bio = newBio;
    if (imageData != null) {
      //check if it's the first time changing profile pic
      if (user.profilePictureRef != null) {
        //new profile pic, delete old one from storage
        deleteImageFromStorage(user.profilePictureRef);
      }
      //set new information to user
      user.profilePictureUrl = imageData['imageUrl'];
      user.profilePictureRef = imageData['storageRef'];
    }
    return _firestore.collection("users").document("${user.uid}").setData(user.userToMap(user));
  }

  Future<void> deleteImageFromStorage(String imageRef) {
    return FirebaseStorage.instance.ref().child(imageRef).delete();
  }

  Future<void> deleteUserPost(String uid, String pid) async {
    DocumentReference _ref = _firestore.collection("users").document(uid);
    //get current user information
    DocumentSnapshot documentSnapshot = await _ref.get();

    //get post information
    documentSnapshot = await _ref.collection("posts").document(pid).get();
    Post post = Post.mapToPost(documentSnapshot.data);

    //first delete post image reference in storage
    deleteImageFromStorage(post.postPhotoRef);

    //second delete document
    await _ref.collection("posts").document(pid).delete();

    //update user post info
    return _changeDocumentFieldValue(_ref, Field.numberOfPosts.name, false);
  }

  Future<List<DocumentSnapshot>> fetchFeed(String currentUserId, bool viewingGroupFeed) async {

    QuerySnapshot _querySnapshot;

    //1.0 create list of hold following userId
    List<String> _userIdFollowing = List<String>();

    //1.1 fetch list of every user being followed by currentUser
    _querySnapshot = await _firestore.collection("users").document(currentUserId).collection("following").getDocuments();

    //1.2 add the userIds to the userIdFollowing list
    for (int i = 0; i < _querySnapshot.documents.length; i++) {

      print(_querySnapshot.documents[i].data['isGroup']);

      //add users depending on if the current user is viewing the group feed or not
      if (viewingGroupFeed) {
        if (_querySnapshot.documents[i].data['isGroup'] == true)
          _userIdFollowing.add(_querySnapshot.documents[i].documentID);
      }
      else {
        if (_querySnapshot.documents[i].data['isGroup'] == false)
          _userIdFollowing.add(_querySnapshot.documents[i].documentID);
      }
    }

    print("FETCH FEED - # OF FOLLOWING IDS: ${_userIdFollowing.length}");

    //2.0 create list to hold every post made by the users in _userIdFollowing
    List<DocumentSnapshot> _postList = List<DocumentSnapshot>();

    //2.2 go through each user and fetch posts
    for (int i = 0; i < _userIdFollowing.length; i++) {
      print("FETCH FEED - FOLLOWING ID: ${_userIdFollowing[i]}");

      _querySnapshot = await _firestore.collection("users").document(_userIdFollowing[i]).collection("posts").getDocuments();

      print("FETCH FEED - # OF POSTS FOR ID: ${_querySnapshot.documents.length}");
      //2.3 add every post to the list
      for (int j = 0; j < _querySnapshot.documents.length; j++) {
        _postList.add(_querySnapshot.documents[j]);
      }

    }

    /*
     *  By this stage the list _postList should contain every post the current user is supposed to see on his feed.
     *  This will be modified to where depending on the toggle, it will include only the groups the current user is following,
     *  or only the friends the current user is following.
     *
     *  From here we need to sort the list by order of timestamp, so that the last posts to be posted appear first.
     */

    print("-----POST LIST BEFORE SORT-----");
    for (int i = 0; i < _postList.length; i++) {
      print(_postList[i].data['timestamp']);
    }

    _postList.sort((a, b) {

      //DateTime timestamp_a = a.data['timestamp'];
      //DateTime timestamp_b = b.data['timestamp'];

      //DateTime date_a = DateTime.fromMillisecondsSinceEpoch(a.data['timestamp']*1000);
      //DateTime date_b = DateTime.fromMillisecondsSinceEpoch(b.data['timestamp']*1000);


      Timestamp date_a = a.data['timestamp'];
      Timestamp date_b = b.data['timestamp'];

      return date_b.seconds.compareTo(date_a.seconds);
    });

    print("-----POST LIST AFTER SORT-----");
    for (int i = 0; i < _postList.length; i++) {
      print(_postList[i].data['timestamp']);
    }

    return _postList;

  }

  Future<QuerySnapshot> searchByName(String searchValue) {
    return _firestore.collection("users").where('searchKey', isEqualTo: searchValue.substring(0, 1).toUpperCase()).getDocuments();
  }
}
