import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/customPost.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/comments_screen.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class FeedUsers extends StatefulWidget {

  final Function changeHomePage;

  FeedUsers({@required this.changeHomePage});

  @override
  _FeedUsersState createState() => _FeedUsersState();
}

class _FeedUsersState extends State<FeedUsers> {

  User _currentUser;
  Future<List<DocumentSnapshot>> _postList;
  bool _viewingGroupFeed = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFeed();
  }

  void fetchFeed() async {
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;

    User user = _currentUser = await _auth.getCurrentUser();
    _postList = _auth.fetchFeed(user.uid, _viewingGroupFeed);

    setState(() {
      this._currentUser = user;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("ENGLife"),
        elevation: 0.0,
        actions: <Widget>[
          _viewingGroupFeed ?
          FlatButton.icon(//if displaying groups
            icon: Icon(Icons.group, color: Colors.white),
            label: Text(
              "Friends",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {

              //TODO: display friend's feed
              _viewingGroupFeed = false;
              fetchFeed();

            },
          ) :
          FlatButton.icon(//if displaying users
            icon: Icon(Icons.person, color: Colors.white),
            label: Text(
              "Groups",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {

              //TODO: display group's feed
              _viewingGroupFeed = true;
              fetchFeed();

            },
          )
        ],
      ),
      body: _currentUser != null ? Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: postsWidget(),
      ) : Center(
        child: Loading(),
      ),
    );
  }

  Widget postsWidget() {
    return FutureBuilder(
      future: _postList,
      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data.length > 0 ?
            ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: ((context, index) => CustomPost(displayedOnFeed: true, documentSnapshot: snapshot.data[index], currentUser: _currentUser, changeHomePage: widget.changeHomePage)),
            ) :
            Center(
              child: Text(
                "No posts available",
                style: TextStyle(
                  fontSize: 35.0,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold
                ),
              ),
            );
          }
          else
            return Center(
              child: Loading(),
            );
        }
        else
          return Center(
            child: Loading(),
          );
      }),
    );
  }
}
