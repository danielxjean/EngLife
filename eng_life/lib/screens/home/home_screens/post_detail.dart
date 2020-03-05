import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/post.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/profile.dart';
import 'package:eng_life/screens/home/home_screens/user_profile.dart';
import 'package:eng_life/services/auth.dart';
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

  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: liked
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
                      setState(() {
                        liked = !liked;
                      });
                    },
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    child: Icon(
                      Icons.comment,
                      size: 40.0,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.documentSnapshot.data['numberOfLikes'] + " likes",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.documentSnapshot.data['caption'],
                style: TextStyle(fontSize: 20.0),
              ),
            )
          ],
        ),
      )
    );
  }
}
