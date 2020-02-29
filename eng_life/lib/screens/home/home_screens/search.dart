import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/home/home_screens/user_profile.dart';
import 'package:eng_life/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  final _auth = AuthService();

  Future<List<DocumentSnapshot>> _future;

  @override
  void initState() {
    super.initState();
    retreiveUsers();
  }

  retreiveUsers() async {
    setState(() {
      _future = _auth.retreiveUsers();
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
                            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  snapshot.data[index].documentID,
                                  style: TextStyle(fontSize: 15.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          print("Tapped on document id: " + snapshot.data[index].documentID);
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (context) => UserProfile(userId: snapshot.data[index].documentID)
                              )
                          );
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
