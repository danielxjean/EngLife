import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/customPost.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/comments_screen.dart';
import 'package:eng_life/screens/home/home_screens/user_profile.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class PostDetail extends StatefulWidget {

  final DocumentSnapshot documentSnapshot;
  final String userId, currentUserId;

  PostDetail({this.documentSnapshot, this.userId, this.currentUserId});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {

  bool _enabledButton = true;
  bool _liked = false;
  bool _displayLiked = false;
  bool _loading = true;
  User _currentUser;
  DocumentSnapshot _documentSnapshot;

  @override
  void initState() {
    super.initState();
    retrieveInformation();
  }

  retrieveInformation() async {
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;
    _displayLiked = _liked = await _auth.checkIfCurrentUserLiked(widget.currentUserId, widget.documentSnapshot.reference);
    _currentUser = await _auth.getCurrentUser();
    _documentSnapshot = await _auth.refreshSnapshotInfo(widget.documentSnapshot);
    if(mounted){
      setState(() {
        _loading = false;
      });
    }
  }

  refreshLikes() async {
    final AuthService _auth = AuthInfo.of(context).authService;
    _documentSnapshot = await _auth.refreshSnapshotInfo(widget.documentSnapshot);
    setState(() {
      print("likes refreshed");
    });
  }

  Future<bool> createDeleteConfirmationDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirm Post Delete"),
            content: Text("Are you sure you want to delete this post?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text("Delete"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? Loading() : Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          title: Text("Post"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: CustomPost(displayedOnFeed: false, documentSnapshot: _documentSnapshot, currentUser: _currentUser, createDeleteConfirmationDialog: createDeleteConfirmationDialog)
        )
    );
  }

  void likePost () async{
    if (!_enabledButton){
      return;
    }
    //lock
    setState(() {
      _enabledButton = false;
      _liked = !_liked;
    });

    final AuthService _auth = AuthInfo.of(context).authService;

    await _auth.likePost(_currentUser, Post.mapToPost(_documentSnapshot.data), widget.documentSnapshot.documentID, _liked).then((_) =>
        refreshLikes());

    setState(() {
      //unlock
      _enabledButton = true;
      _displayLiked = _liked;
    });
  }
}
