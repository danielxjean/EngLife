import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/user_profile.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {

  PageController pageController;

  Search({this.pageController});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  User _currentUser;

  Future<List<DocumentSnapshot>> _future;

  @override
  void initState() {
    super.initState();
    retrieveUsers();
  }

  retrieveUsers() async {
    //final AuthService _auth = AuthInfo.of(context).authService; //use line below this one instead when called from initState().
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;
    _currentUser = await _auth.getCurrentUser();
    setState(() {
      _future = _auth.retrieveUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("Search Users"),
      ),
      body: Container(
        child: FutureBuilder(
          future: _future,
          builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(snapshot.data.length);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Card(
                          margin: const EdgeInsets.all(10.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: CachedNetworkImageProvider(
                                    snapshot.data[index].data['profilePictureUrl']
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  snapshot.data[index].data['displayName'],
                                  style: TextStyle(fontSize: 20.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          print("Tapped on document id: " + snapshot.data[index].documentID);

                          if (snapshot.data[index].documentID == _currentUser.uid) {
                            widget.pageController.jumpToPage(3);
                          }
                          else {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserProfile(userId: snapshot.data[index]
                                            .documentID)
                                )
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              }
              else {
                print("Connection not done");
                return Container();
              }
            }
            else {
              print("Snapshot has no data");
              return Container();
            }
          }),
        ),
      )
    );
  }
}
