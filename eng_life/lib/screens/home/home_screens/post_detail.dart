import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/profile.dart';
import 'package:eng_life/screens/home/home_screens/user_profile.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class PostDetail extends StatefulWidget {

  DocumentSnapshot documentSnapshot;
  String userId, currentUserId;

  PostDetail({this.documentSnapshot, this.userId, this.currentUserId});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {

  final _auth = AuthService();

  bool _liked = false;
  bool _loading = true;
  User _currentUser;
  DocumentSnapshot _documentSnapshot;

  @override
  void initState() {
    super.initState();
    retreiveInformation();
  }

  retreiveInformation() async {
    _liked = await _auth.checkIfCurrentUserLiked(widget.currentUserId, widget.documentSnapshot.reference);
    _currentUser = await _auth.getCurrentUser();
    _documentSnapshot = await _auth.refreshSnapshotInfo(widget.documentSnapshot);
    setState(() {
      _loading = false;
    });
  }

  refreshLikes() async {
    _documentSnapshot = await _auth.refreshSnapshotInfo(widget.documentSnapshot);
    setState(() {
      print("likes refreshed");
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading == true ? Loading() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("Post"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      widget.documentSnapshot.data['userProfilePictureUrl']
                    ),
                    radius: 25.0,
                  ),
                  SizedBox(width: 5.0),
                  GestureDetector(
                    child: Text(
                      widget.documentSnapshot.data['displayName'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    onTap: () {
                      if (widget.userId == widget.currentUserId) {
                        Navigator.pop(context);
                      }
                      else {
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return UserProfile(userId: widget.userId);

                                }
                            )
                        );
                      }
                    },
                  )
                ],
              ),
            ),
            CachedNetworkImage(
              imageUrl: widget.documentSnapshot.data['postPhotoUrl'],
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
                      //Post.mapToPost(widget.documentSnapshot.data);
                      //widget.currentUserId
                      //widget.documentSnapshot.documentID
                      if (_liked == true) {
                        //unlike post
                        _auth.deleteLikeFromPost(_currentUser, Post.mapToPost(_documentSnapshot.data), widget.documentSnapshot.documentID);
                        setState(() {
                          _liked = false;
                          refreshLikes();
                        });
                      }
                      else {
                        //like post
                        _auth.addLikeToPost(_currentUser, Post.mapToPost(_documentSnapshot.data), widget.documentSnapshot.documentID);
                        setState(() {
                          _liked = true;
                          refreshLikes();
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

                      

                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _documentSnapshot.data['numberOfLikes'] + " likes",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _documentSnapshot.data['caption'],
                style: TextStyle(fontSize: 20.0),
              ),
            )
          ],
        ),
      )
    );
  }
}
