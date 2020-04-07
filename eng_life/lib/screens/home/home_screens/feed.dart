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

class Feed extends StatefulWidget {

  final Function onStateChanged;

  Feed({@required this.onStateChanged});

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  User _currentUser;
  Future<List<DocumentSnapshot>> _postList;
  bool _liked = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFeed();
  }

  void fetchFeed() async {
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;

    User user = _currentUser = await _auth.getCurrentUser();
    _postList = _auth.fetchFeed(user.uid);

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
      ),
      body: _currentUser != null ? Padding(
        padding: const EdgeInsets.only(top: 4.0),
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
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: ((context, index) => CustomPost(displayedOnFeed: true, documentSnapshot: snapshot.data[index], currentUser: _currentUser, onStateChanged: widget.onStateChanged)),
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
