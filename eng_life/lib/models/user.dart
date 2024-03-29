class User {

  String uid;
  String username;
  String email;
  String profilePictureUrl;
  String profilePictureRef;
  String displayName;
  String numOfFollowers;
  String numOfFollowing;
  String numOfPosts;
  String bio;
  String educationMajor;
  bool isGroup;
  bool firstLogin;

  User({this.uid, this.email, this.profilePictureUrl, this.profilePictureRef, this.displayName, this.numOfFollowers, this.numOfFollowing, this.numOfPosts, this.bio, this.educationMajor, this.username, this.isGroup, this.firstLogin});


  Map<String, dynamic> userToMap(User user) {
    var map = Map<String, dynamic>();
    map['uid'] = user.uid;
    map['email'] = user.email;
    map['profilePictureUrl'] = user.profilePictureUrl;
    map['profilePictureRef'] = user.profilePictureRef;
    map['displayName'] = user.displayName;
    map['numOfFollowers'] = user.numOfFollowers;
    map['numOfFollowing'] = user.numOfFollowing;
    map['numOfPosts'] = user.numOfPosts;
    map['bio'] = user.bio;
    map['educationMajor'] = user.educationMajor;
    map['username'] = user.username;
    map['isGroup'] = user.isGroup;
    map['firstLogin'] = user.firstLogin;
    return map;
  }

  User.mapToUser(Map<String, dynamic> map) {
    this.uid = map['uid'];
    this.email = map['email'];
    this.profilePictureUrl = map['profilePictureUrl'];
    this.profilePictureRef = map['profilePictureRef'];
    this.displayName = map['displayName'];
    this.numOfFollowers = map['numOfFollowers'];
    this.numOfFollowing = map['numOfFollowing'];
    this.numOfPosts = map['numOfPosts'];
    this.bio = map['bio'];
    this.educationMajor = map['educationMajor'];
    this.username = map['username'];
    this.isGroup = map['isGroup'];
    this.isGroup = map['isGroup'];
    this.firstLogin = map['firstLogin'];
  }

  @override
  String toString() {
    print("${this.firstLogin} ${this.isGroup} $displayName");
    return super.toString();
  }


}