import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/shared/loading.dart';

class ClubsPage extends StatefulWidget {
  @override
  final User user;
  final String userId;
  final Function toggleView;

  ClubsPage({this.userId, this.user, this.toggleView});

  _ClubsPage createState() => _ClubsPage();
}

class _ClubsPage extends State<ClubsPage> {

  // maybe you can make a count or a method in_auth later

  var _isFollowing = [false, false, false, false, false, false, false, false, false, false, false, false, false];
  AuthService _auth = AuthService();
  User _user;
  User _currentUser;
//  bool _isFollowing;
  bool firstLogin = true;
  bool _loading = false;
  Future<List<DocumentSnapshot>> _future;

  @override
  void initState() {
    super.initState();
    refreshUserDetails();
    setState(() {
      retrieveUserDetails();
//      _isFollowing = false;
    });
  }

  refreshUserDetails() async {
    _user = await _auth.getUser(widget.userId);
    setState(() {
      print("user refreshed");
    });
  }

  retrieveUserDetails() async {
    _user = await _auth.getUser(widget.userId);
//    _currentUser = await _auth.getCurrentUser(); // maybe if we comment this out
    setState(() {
      _future = _auth.retrieveGroups();
      _loading = false;
    });
  }

    @override
    Widget build(BuildContext context) {
      return _loading == true ? Loading() : Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          title: Text("ENGLife"),
          centerTitle: true,
          elevation: 1.0,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              listOfClubs(),
              SizedBox(width: 20.0),
              RaisedButton(
                color: Colors.red[900],
                child: Text(
                  "Go to homepage",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  print("button pressed, user now able to go to home page");
                  _loading = true;
                  _auth.updateUserFirstLogin(widget.user, false);
                  widget.toggleView();
                },
              ),
            ],
          ),
        ),
      );
    }

    Widget listOfClubs() {
      return Flexible(
        child: Container(
          child: FutureBuilder(
            future: _future,
            builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) {
                print("NO DATA FOR THE LIST OF CLUBS");
                return (Center(child: CircularProgressIndicator()));
              } else {
                return
                  Container(
                    child:
                    ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: ((context, index) =>
                          listGroups(snapshot.data[index], index)),
                    ),
                  );
               }
            }),
          ),
        ),
      );
    }

    Widget listGroups(DocumentSnapshot documentSnapshot, int index) {
//    _isFollowing = documentSnapshot.
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    documentSnapshot.data['profilePictureUrl']),
                radius: 20.0,
              ),
            ),
          SizedBox(
            width: 15.0,
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(documentSnapshot.data['displayName'], style: TextStyle(fontWeight: FontWeight.bold,)),
              ),
              FlatButton(
                color: Colors.red[900],
                textColor: Colors.grey[100],
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.red[900],
                child: _isFollowing[index] == true ? Text("Unfollow", style: TextStyle(fontSize: 20.0),) : Text("Follow", style: TextStyle(fontSize: 20.0), textAlign: TextAlign.right,),
                onPressed: () async {

                  if (_isFollowing[index] == true) {
                    _auth.removeUserFollow(_user, _currentUser ??= await _auth.getUser(documentSnapshot.data["uid"]),);
                    refreshUserDetails();
                    _isFollowing[index] = false;
                    setState(() {

                    });
                  } else {
                    _auth.addUserFollow(_user, await _auth.getUser(documentSnapshot.data["uid"]),);
                    refreshUserDetails();
                    _isFollowing[index] = true;
                    setState(() {

                    });
                  }
                }
              ),
            ],
          ),
          ],
        ),
      );
    }
  }

