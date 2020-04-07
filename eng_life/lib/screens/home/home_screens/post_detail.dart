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
    _currentUser = await _auth.getCurrentUser();
    _documentSnapshot = await _auth.refreshSnapshotInfo(widget.documentSnapshot);
    if(mounted){
      setState(() {
        _loading = false;
      });
    }
  }

  refreshPage() async {
    final AuthService _auth = AuthInfo.of(context).authService;
    _currentUser = await _auth.getCurrentUser();
    _documentSnapshot = await _auth.refreshSnapshotInfo(widget.documentSnapshot);
    setState(() {
      _loading = false;
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
        body: CustomPost(displayedOnFeed: false, documentSnapshot: _documentSnapshot, currentUser: _currentUser, createDeleteConfirmationDialog: createDeleteConfirmationDialog, returnFromDeletedPost: refreshPage)
    );
  }
}
