
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<DocumentSnapshot>> retreiveUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection("users").getDocuments();
    return querySnapshot.documents;
  }

}