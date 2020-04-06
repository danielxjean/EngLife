
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/like.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  String _displayName = "Default";
  bool _isGroup = false;
  bool _firstLogin = true;

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
          displayName: _displayName,
          educationMajor: 'Default',
          numOfPosts: '0',
          numOfFollowers: '0',
          numOfFollowing: '0',
          //added here
          profilePictureUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png",
          username: "Default",//username input needs to be added to register form, must be unique
          isGroup: _isGroup,
          firstLogin: _firstLogin);
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
  Future registerWithEmailAndPassword(String email, String password, String displayName, bool isGroup, bool firstLogin) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      print("PRINTING FROM REGISTER****: " + firebaseUser.toString());

      this._displayName = displayName;
      this._isGroup = isGroup;
      this._firstLogin = firstLogin;

      createNewUserInDatabase(_userFromFirebaseUser(firebaseUser));
      return _userFromFirebaseUser(firebaseUser);
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

  //registerGroupWithEmailAndPassword

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
  Future<void> addPostToDb(Map<String, String> imageData, String caption, User user) {
    CollectionReference _collectionRef = _firestore.collection("users").document("${user.uid}").collection("posts");

    print("IMAGE URL: ${imageData['imageUrl']}");


    Post post = Post(
        userId: user.uid,
        postPhotoUrl: imageData['imageUrl'],
        postPhotoRef: imageData['storageRef'],
        caption: caption,
        displayName: user.displayName,
        userProfilePictureUrl: user.profilePictureUrl,
        numberOfLikes: "0");

    //add post to db
    _collectionRef.add(post.toMap(post));

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
  Future<void> userFollow(User curUser, User user2, bool add) async{
    await (add
        ? _addUserFollow(curUser, user2)
        : _removeUserFollow(curUser, user2)
    );
  }
  //endregion

  //region Split follow/unfollow routines
  //curUser will follow user2.
  Future<void> _addUserFollow(User curUser, User user2) async{
    await Future.wait([
    _userAsFollowerOf(curUser.uid, user2, true),
    _userAsFollowing(curUser, user2.uid, true)
    ]);
  }
  //curUser will unfollow user2.
  Future<void> _removeUserFollow(User curUser, User user2) async {
    await Future.wait([
      _userAsFollowerOf(curUser.uid, user2, false),
      _userAsFollowing(curUser, user2.uid, false)
    ]);
  }
  //endregion

  //region Handle synchronization
  Future<void> _userAsFollowerOf(String curUserId, User user2, bool addFollow) async{
    String uid2 = user2.uid;
    //Wait
    if (_isFollowed[uid2] != null){
      await _isFollowed[uid2];
      return _userAsFollowerOf(curUserId, user2, addFollow);
    }
    //Lock
    Completer completer = Completer<Null>();
    _isFollowed[uid2] = completer.future;

    //Critical Section
    addFollow ? await _addUserAsFollowerOf(curUserId, user2)
        : await _removeUserAsFollowerOf(curUserId, user2);

    //Unlock
    completer.complete();
    _isFollowed[uid2] = null;
  }
  Future<void> _userAsFollowing(User curUser, String uid2, bool addFollow) async{
    String curUserId = curUser.uid;
    //Wait
    if (_isFollowing[curUserId] != null){
      await _isFollowing[curUserId];
      return _userAsFollowing(curUser, uid2, addFollow);
    }
    //Lock
    Completer completer = Completer<Null>();
    _isFollowing[curUserId] = completer.future;

    //Critical Section
    addFollow ? await _addUserAsFollowing(curUser, uid2)
        : await _removeUserAsFollowing(curUser, uid2);

    //Unlock
    completer.complete();
    _isFollowing[curUserId] = null;
  }
  //endregion

  //region Follow/Following Methods
  Future<void> _addUserAsFollowerOf(String curUserId, User user2) async{
    String uid2 = user2.uid;
    DocumentReference _ref = _firestore.collection("users").document(uid2);
    Map<String, dynamic> map = {'userid': curUserId};
    _ref.collection("followers").document(curUserId).setData(map);
    
	  //update number of followers
    return _changeDocumentFieldValue(_ref, Field.numberOfFollowers.name, true);
  }
  
  Future<void> _addUserAsFollowing(User curUser, String uid2) async{
    String curUserId = curUser.uid;
    DocumentReference _ref = _firestore.collection("users").document(curUserId);
    Map<String, dynamic> map = {'userid': uid2};
    _ref.collection("following").document(uid2).setData(map);

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

  //region Like Dislike Methods
  Future<void> _addLikeToPost(User curUser, Post likedPost, String postId) async{
    DocumentReference _ref = _firestore.collection("users").document(likedPost.userId).collection("posts").document("$postId");
    //Will construct like.
    Like like = Like(displayName: curUser.displayName, profilePictureUrl: curUser.profilePictureUrl, uid: curUser.uid);
    //convert Like to map.
    Map map = like.toMap();

    await _ref.collection("likes").document(curUser.uid).setData(map);

    //update post's number of likes.
    return _changeDocumentFieldValue(_ref, Field.numberOfLikes.name, true);

  
  Future<void> _deleteLikeFromPost(User curUser, Post likedPost, String postId) async{
    DocumentReference _ref = _firestore.collection("users").document(likedPost.userId).collection("posts").document("$postId");
    //print('del: ${(await _ref.document(curUser.uid).get()).data}');
    await _ref.collection("likes").document(curUser.uid).delete();
    

    //update post's number of likes.
    return _changeDocumentFieldValue(_ref, Field.numberOfLikes.name, false);
  }
  
  //endregion
  //endregion

  Future<List<DocumentSnapshot>> retrieveUsers() async {
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
      if (user.profilePictureRef == null) {
        //first time changing profile picture, no need to delete any old ones
        user.profilePictureUrl = imageData['imageUrl'];
        user.profilePictureRef = imageData['storageRef'];
      }
      else {
        //new profile pic, delete old one from storage
        deleteImageFromStorage(user.profilePictureRef);
        //set new information to user
        user.profilePictureUrl = imageData['imageUrl'];
        user.profilePictureRef = imageData['storageRef'];
      }
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


}
