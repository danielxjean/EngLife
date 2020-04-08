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

  Future<List<DocumentSnapshot>> _future;
  TextEditingController _searchController = TextEditingController();

  var _queryResultSet = [];
  var _tempSearchStore = [];


  @override
  void initState() {
    super.initState();
    initiateSearch("");
    _searchController.text = "";
  }
  /*
  retrieveUsers() async {
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;
    _currentUser = await _auth.getCurrentUser();
    if(mounted){
      setState(() {
        //_future = _auth.retrieveUsers();
      });
    }
  }
  */
  
  initiateSearch(String text) async {
    final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;

    print("result set: ${_queryResultSet.length}");
    print("text length: ${text.length}");

    if (text.length == 0) {
      _queryResultSet = [];
      _tempSearchStore = [];

      await _auth.retrieveUsers().then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          _queryResultSet.add(docs.documents[i].data);
        }
      });

      _queryResultSet.forEach((element) {
        String displayName = element['displayName'];
        if (displayName.toUpperCase().startsWith(text.toUpperCase())) {
          setState(() {
            _tempSearchStore.add(element);
          });
        }
      });
    }
    /*
    if (_queryResultSet.length == 0 && text.length == 1) {
      await _auth.searchByName(text).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          _queryResultSet.add(docs.documents[i].data);
        }
      });

      _tempSearchStore = [];
      _queryResultSet.forEach((element) {
        if (element['displayName'].startsWith(text)) {
          setState(() {
            _tempSearchStore.add(element);
          });
        }
      });
    }
    */
    else {
      _tempSearchStore = [];
      _queryResultSet.forEach((element) {
        String displayName = element['displayName'];
        if (displayName.toUpperCase().startsWith(text.toUpperCase())) {
          setState(() {
            _tempSearchStore.add(element);
          });
        }
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: 20.0, color: Colors.black),
          maxLines: 1,
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.only(left: 12.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(15)
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(15)
            )
          ),
          onChanged: (text) {
            //TODO SEARCH THE DATABASE AFTER EVERY MODIFICATION AND UPDATE LIST OF USERS
            print(text);
            initiateSearch(text);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _tempSearchStore.map((element) {
            return buildUserCard(element);
          }).toList()
        ),
      )
    );
  }

  Widget buildUserCard(data) {
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
                    data['profilePictureUrl']
                ),
              ),
              SizedBox(width: 10.0),
              Text(
                data['displayName'],
                style: TextStyle(fontSize: 20.0),
              )
            ],
          ),
        ),
      ),
      onTap: () async {
        final AuthService _auth = AuthInfo.of(context).authService;
        User _currentUser = await _auth.getCurrentUser();

        print("Tapped on document id: ${data['uid']}");

        if (data['uid'] == _currentUser.uid) {
          widget.pageController.jumpToPage(3);
        }
        else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(userId: data['uid'])));
        }
      }
    );
  }
}

/*
Container(
        child: GridView.count(
          physics: ScrollPhysics(),
          crossAxisCount: 1,
          shrinkWrap: true,
          mainAxisSpacing: 2.0,
          primary: false,
          children: _tempSearchStore.map((element) {
            return buildUserCard(element);
          }).toList(),
        )
      )
 */

/*
FutureBuilder(
          future: _future,
          builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(snapshot.data.length);
                return Padding(
                  padding: const EdgeInsets.all(0),
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
 */
