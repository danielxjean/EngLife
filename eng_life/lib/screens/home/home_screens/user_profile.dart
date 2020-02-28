import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/post_detail.dart';
import 'package:eng_life/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {

  DocumentSnapshot documentSnapshot;

  UserProfile({this.documentSnapshot});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  AuthService _auth = AuthService();
  User _currentUser;
  Future<List<DocumentSnapshot>> _future;

  @override
  void initState() {
    super.initState();
    retreiveUserDetails();
  }

  retreiveUserDetails() async {
    FirebaseUser currentUser = await _auth.getCurrentUser();
    User user = User(uid: currentUser.uid);
    setState(() {
      this._currentUser = user;
      _future = _auth.retreiveUserPhotos(widget.documentSnapshot.documentID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentSnapshot.documentID),
        backgroundColor: Colors.red[900],
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.red[900],
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(

                ),
                SizedBox(height: 10.0),
                Text(
                  "Bio here",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                    color: Colors.grey[200],
                    child: Text("Follow"),
                    onPressed: () {
                      print("You pressed me");
                    }
                )
              ],
            ),
          ),
          FutureBuilder(
            future: _future,
            builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: ((context, index) {
                        return GestureDetector(
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data[index].data['imageUrl'],
                            width: 125.0,
                            height: 125.0,
                            fit: BoxFit.cover,
                          ),
                          onTap: () {
                            var currentUser;
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) => PostDetail(documentSnapshot: snapshot.data[index], userId: _currentUser.uid, currentUserId: _currentUser.uid,)
                                )
                            );
                          },
                        );
                      }),
                    ),
                  );
                }
                else
                  return Container();
              }
              else
                return Container();
            }),
          )
        ],
      ),
    );
  }
}
