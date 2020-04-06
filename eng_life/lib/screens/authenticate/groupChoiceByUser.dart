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
  List<bool> _isFollowing;

  AuthService _auth = AuthService();
  User _user;
  User _currentUser;
  bool firstLogin = true;
  bool _loading = false;
  Future<List<DocumentSnapshot>> _futureGroupDocuments;
  Future<void> _futureGroupsFollowed;
  Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    retrieveUserDetails();
  }

  refreshUserDetails() async {
    _user = await _auth.getUser(widget.userId);
    setState(() {
      print("user refreshed");
    });
  }

  Future<void> iterateCheckGroupFollowed(List<DocumentSnapshot> list) async {
    for(int i = 0; i < list.length; i++){
      _isFollowing[i] = (await _auth.checkIfCurrentUserIsFollowing(list[i].documentID, _currentUser.uid));
    }
  }

  retrieveUserDetails() async {

    _futureUser = _auth.getCurrentUser();
    _futureGroupDocuments = _futureUser.then((_) => _auth.retrieveGroups());
    _futureGroupsFollowed = _futureGroupDocuments.then((future) async{_isFollowing = List(future.length); return await iterateCheckGroupFollowed(future);});
    //_future2 = _future.then((future) {_isFollowing = List(); future.forEach((document) async{_isFollowing.add(await _auth.checkIfCurrentUserIsFollowing(document.documentID, _currentUser.uid));});});
    //_user = await _auth.getUser(widget.userId); //  <--widget.userId was passed as the current user's id.
    _currentUser = await _futureUser;
   _loading = false;
  }

    @override
    Widget build(BuildContext context) {
      return _loading ? Loading() : Scaffold(
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
            future: _futureGroupsFollowed.then((_)=> _futureGroupDocuments),
            builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) {
                print("NO DATA FOR THE LIST OF CLUBS");
                return (Center(child: CircularProgressIndicator()));
              } else {
                print(_isFollowing);
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
                child: _isFollowing[index] ? Text("Unfollow", style: TextStyle(fontSize: 20.0),) : Text("Follow", style: TextStyle(fontSize: 20.0), textAlign: TextAlign.right,),
                onPressed: () async {
                  print('pressed ${_isFollowing[index]} $index $_isFollowing');
                  User group = await _auth.getUser(documentSnapshot.documentID);
                  if (_isFollowing[index]) {
                    refreshUserDetails();
                    _auth.removeUserFollow(_currentUser, group);
                    setState(() {
                      _isFollowing[index] = false;
                    });
                  } else {
                    refreshUserDetails();
                    _auth.addUserFollow(_currentUser, group);
                    setState(() {
                      _isFollowing[index] = true;
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

