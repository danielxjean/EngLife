import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/comments_screen.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
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
              itemBuilder: ((context, index) => post(
                list: snapshot.data, user: _currentUser, index: index
              )),
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

  Widget post({List<DocumentSnapshot> list, User user, int index}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  list[index].data['userProfilePictureUrl']
                ),
                radius: 25.0,
              ),
              SizedBox(width: 5.0),
              GestureDetector(
                child: Text(
                  list[index].data['displayName'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                onTap: () {

                  //TODO redirect to user_profile page

                },
              )
            ],
          ),
        ),
        CachedNetworkImage(
          imageUrl: list[index].data['postPhotoUrl'],
          placeholder: ((context, s) => Center(
            child: Loading(),
          )),
          height: 400.0,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                child: _liked
                    ? Icon(
                  Icons.favorite,
                  color: Colors.red[900],
                  size: 40.0,
                )
                    : Icon(
                  Icons.favorite_border,
                  size: 40.0,
                ),
                onTap: () {
                  final AuthService _auth = AuthInfo.of(context).authService;
                  //Post.mapToPost(widget.documentSnapshot.data);
                  //widget.currentUserId
                  //widget.documentSnapshot.documentID
                  if (_liked == true) {
                    //unlike post
                    _auth.deleteLikeFromPost(_currentUser, Post.mapToPost(list[index].data), list[index].documentID);
                    setState(() {
                      _liked = false;
                    });
                  }
                  else {
                    //like post
                    _auth.addLikeToPost(_currentUser, Post.mapToPost(list[index].data), list[index].documentID);
                    setState(() {
                      _liked = true;
                    });
                  }
                },
              ),
              SizedBox(width: 15),
              GestureDetector(
                child: Icon(
                  Icons.comment,
                  size: 40.0,
                ),
                onTap: () {

                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => CommentsPage(user: _currentUser, documentReference: list[index].reference)
                      )
                  );

                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            list[index].data['numberOfLikes'] + " likes",
            style: TextStyle(fontSize: 15.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: <Widget>[
              Text(
                list[index].data['displayName'],
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5.0),
              Text(
                list[index].data['caption'],
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0)
      ],
    );
  }
}
