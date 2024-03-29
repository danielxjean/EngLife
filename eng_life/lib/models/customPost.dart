import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home.dart';
import 'package:eng_life/screens/home/home_screens/comments_screen.dart';
import 'package:eng_life/screens/home/home_screens/user_profile.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class CustomPost extends StatefulWidget {

  final DocumentSnapshot documentSnapshot;
  final User currentUser;
  final Function createDeleteConfirmationDialog;
  final Function changeHomePage;
  final bool displayedOnFeed;

  CustomPost({this.documentSnapshot, this.currentUser, this.createDeleteConfirmationDialog, this.displayedOnFeed, this.changeHomePage});

  @override
  _CustomPostState createState() => _CustomPostState();
}

class _CustomPostState extends State<CustomPost> {

  bool _enabledButton = true;
  bool _liked = false;
  bool _displayLiked = false;
  bool _loading = false;
  DocumentSnapshot _documentSnapshot;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isPostLiked();
  }

  isPostLiked() async {
    _documentSnapshot = widget.documentSnapshot;
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;
    _displayLiked = _liked = await _auth.checkIfCurrentUserLiked(widget.currentUser.uid, widget.documentSnapshot.reference);
    _documentSnapshot = await _auth.refreshSnapshotInfo(widget.documentSnapshot);
    if (mounted) {
      setState(() {
        print("CustomPost(): Retrieved info for liked and document snapshot");
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

  likePost () async{
    if (!_enabledButton){
      return;
    }
    //lock
    setState(() {
      _enabledButton = false;
      _liked = !_liked;
    });

    final AuthService _auth = AuthInfo.of(context).authService;

    await _auth.likePost(widget.currentUser, Post.mapToPost(_documentSnapshot.data), _documentSnapshot.documentID, _liked).then((_) =>
        refreshLikes());

    setState(() {
      //unlock
      _enabledButton = true;
      _displayLiked = _liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? Loading() : Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            _documentSnapshot.data['userProfilePictureUrl']
                        ),
                        radius: 25.0,
                      ),
                      SizedBox(width: 5.0),
                      GestureDetector(
                        child: Text(
                          _documentSnapshot.data['displayName'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          key: Key('displayName')
                        ),
                        onTap: () {
                          if (_documentSnapshot.data['userId'] == widget.currentUser.uid && widget.displayedOnFeed == false) {
                            Navigator.of(context).pop();
                          }
                          else if (_documentSnapshot.data['userId'] == widget.currentUser.uid && widget.displayedOnFeed == true) {
                            widget.changeHomePage(3);
                          }
                          else {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return UserProfile(userId: _documentSnapshot.data['userId']);
                                    }
                                )
                            );
                          }
                        },
                      )
                    ],
                  ),
                  (!widget.displayedOnFeed && _documentSnapshot.data['userId'] == widget.currentUser.uid) ? IconButton(
                    icon: Icon(Icons.delete),
                    key: Key('delete'),
                    onPressed: () async {
                      final AuthService _auth = AuthInfo.of(context).authService;
                      if (await widget.createDeleteConfirmationDialog(context)) {
                        setState(() {
                          _loading = true;
                        });
                        await _auth.deleteUserPost(widget.currentUser.uid, _documentSnapshot.documentID);
                        widget.changeHomePage();
                        Navigator.of(context).pop();
                      }
                    },
                  ) : Container(/* Don't shot the delete icon */)
                ],
              ),
            ),
            GestureDetector(
              child: CachedNetworkImage(
                key: Key('image'),
                imageUrl: _documentSnapshot.data['postPhotoUrl'],
                height: 400.0,
                fit: BoxFit.cover,
              ),
              onDoubleTap: (){
                likePost();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    child: _displayLiked
                        ? Icon(
                      Icons.favorite,
                      color: Colors.red[900],
                      size: 40.0,
                      key: Key('liked'),
                    )
                        : Icon(
                      Icons.favorite_border,
                      size: 40.0,
                      key: Key('unliked'),
                    ),
                    onTap: ()   {
                      likePost();
                    },
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    child: Icon(
                      Icons.comment,
                      size: 40.0,
                      key: Key('comment'),
                    ),
                    onTap: () {

                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => CommentsPage(user: widget.currentUser, documentReference: _documentSnapshot.reference)
                          )
                      );

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
      ),
    );
  }
}
