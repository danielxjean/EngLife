import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    _liked = await _auth.checkIfCurrentUserLiked(widget.currentUserId, widget.documentSnapshot.reference);
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

  Future<bool> createConfirmationDialog(BuildContext context) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
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
                    widget.userId == widget.currentUserId ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        final AuthService _auth = AuthInfo.of(context).authService;
                        if (await createConfirmationDialog(context) == true) {
                          print("Delete post");
                          setState(() {
                            _loading = true;
                          });
                          await _auth.deleteUserPost(widget.userId, widget.documentSnapshot.documentID);
                          Navigator.of(context).pop();
                        }
                        else {
                          //do nothing
                        }
                      },
                    ) : Container()
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
                      onTap: ()   {
                         likePost();
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
                                builder: (context) => CommentsPage(user: _currentUser, documentReference: widget.documentSnapshot.reference)
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
    });

    final AuthService _auth = AuthInfo.of(context).authService;

    await _auth.likePost(_currentUser, Post.mapToPost(_documentSnapshot.data), widget.documentSnapshot.documentID, !_liked);

    setState(() {
      _liked = !_liked;
      refreshLikes();

      //unlock
      _enabledButton = true;
    });
  }
}
