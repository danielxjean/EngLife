class User {

  String uid;
  String username;
  String email;
  String profilePictureUrl;
  String displayName;
  String numOfFollowers;
  String numOfFollowing;
  String numOfPosts;
  String bio;
  String educationMajor;

  User({this.uid, this.email, this.profilePictureUrl, this.displayName, this.numOfFollowers, this.numOfFollowing, this.numOfPosts, this.bio, this.educationMajor, this.username});

  Map<String, dynamic> userToMap(User user) {
    var map = Map<String, dynamic>();
    map['uid'] = user.uid;
    map['email'] = user.email;
    map['profilePictureUrl'] = user.profilePictureUrl;
    map['displayName'] = user.displayName;
    map['numOfFollowers'] = user.numOfFollowers;
    map['numOfFollowing'] = user.numOfFollowing;
    map['numOfPosts'] = user.numOfPosts;
    map['bio'] = user.bio;
    map['educationMajor'] = user.educationMajor;
    map['username'] = user.username;
    return map;
  }

  User.mapToUser(Map<String, dynamic> map) {
    this.uid = map['uid'];
    this.email = map['email'];
    this.profilePictureUrl = map['profilePictureUrl'];
    this.displayName = map['displayName'];
    this.numOfFollowers = map['numOfFollowers'];
    this.numOfFollowing = map['numOfFollowing'];
    this.numOfPosts = map['numOfPosts'];
    this.bio = map['bio'];
    this.educationMajor = map['educationMajor'];
    this.username = map['username'];
  }



}