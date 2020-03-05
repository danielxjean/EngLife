import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                    backgroundImage: NetworkImage('https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Art/defaultphoto_2x.png'),
                    radius: 25.0,
                  ),
                  SizedBox(width: 5.0),
                  GestureDetector(
                    child: Text(
                      widget.userId,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) {
                                if (widget.userId == widget.currentUserId) {

                                  /*

                                  Must change the fow here to go back to the home page showing profile.
                                  Or else user can loop infinitely to his profile creating a new page every time and eventually
                                  causing a stack overflow

                                   */

                                  return Profile();
                                }
                                else {
                                  return UserProfile(userId: widget.userId);
                                }
                              }
                          )
                      );
                    },
                  )
                ],
              ),
            ),
            CachedNetworkImage(
              imageUrl: widget.documentSnapshot.data['imageUrl'],
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
                "Caption goes over here",
                style: TextStyle(fontSize: 15.0),
              ),
            )
          ],
        ),
      )
    );
  }
}
