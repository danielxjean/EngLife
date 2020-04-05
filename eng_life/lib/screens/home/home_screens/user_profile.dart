import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/post_detail.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {

  final String userId;

  UserProfile({this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  User _currentUser;
  User _user;
  Future<List<DocumentSnapshot>> _future;

  bool _loading = true;
  bool _isFollowing = false;
  bool _enabledButton = true;

  @override
  void initState() {
    super.initState();
    retrieveUserDetails();
  }

  retrieveUserDetails() async {
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;
    _user = await _auth.getUser(widget.userId);
    _currentUser = await _auth.getCurrentUser();
    _isFollowing = await _auth.checkIfCurrentUserIsFollowing(widget.userId, _currentUser.uid);
    if(mounted){
      setState(() {
        _future = _auth.retrieveUserPosts(widget.userId);
        _loading = false;
      });
    }
  }

  refreshUserDetails() async {
    final AuthService _auth = AuthInfo.of(context).authService;
    _user = await _auth.getUser(widget.userId);
    //since there's a set state after this method is called, this one is redundant.
    //setState(() {
      print("user refreshed");
    //});
  }

  @override
  Widget build(BuildContext context) {
    return _loading == true ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text(_user.username),
        backgroundColor: Colors.red[900],
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.red[900],
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          _user.profilePictureUrl
                      ),
                      radius: 50.0,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          _user.numOfPosts,
                          style: TextStyle(color: Colors.grey[100], fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        Text(
                          "Posts",
                          style: TextStyle(color: Colors.grey[100], fontSize: 18.0),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          _user.numOfFollowers,
                          style: TextStyle(color: Colors.grey[100], fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        Text(
                          "Followers",
                          style: TextStyle(color: Colors.grey[100], fontSize: 18.0),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          _user.numOfFollowing,
                          style: TextStyle(color: Colors.grey[100], fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        Text(
                          "Following",
                          style: TextStyle(color: Colors.grey[100], fontSize: 18.0),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 10.0),
                Text(
                  _user.displayName,
                  style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  _user.bio,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                    color: Colors.grey[200],
                    child: _isFollowing == true ? Text("Unfollow") : Text("Follow"),
                    onPressed: () {
                      followUser();
                    }
                )
              ],
            ),
          ),
          FutureBuilder(
            future: _future,
            builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: ((context, index) {
                        return GestureDetector(
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data[index].data['postPhotoUrl'],
                            width: 125.0,
                            height: 125.0,
                            fit: BoxFit.cover,
                          ),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) => PostDetail(documentSnapshot: snapshot.data[index], userId: widget.userId, currentUserId: _currentUser.uid)
                                )
                            );
                          },
                        );
                      }),
                    ),
                  );
                }
                else
                  return Container();
              }
              else
                return Container();
            }),
          )
        ],
      ),
    );
  }

  void followUser () async{
    if (!_enabledButton){
      return;
    }
    setState(() {
      //lock
      _enabledButton = false;
      _isFollowing = !_isFollowing;
    });

    final AuthService _auth = AuthInfo.of(context).authService;

    //set to negation beforehand to synchronize better. Not as necessary since the button is being disabled (otherwise it would be).
    await _auth.userFollow(_currentUser, _user, _isFollowing).then((_) => refreshUserDetails());

    setState(() {
      //unlock
      _enabledButton = true;
    });
  }
}
