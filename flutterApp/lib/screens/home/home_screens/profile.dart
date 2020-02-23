import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final _auth = AuthService();
  User _user;
  Future<List<DocumentSnapshot>> _future;

  List<Widget> photos = [];

  @override
  void initState() {
    super.initState();
    retreiveUserDetails();
  }

  retreiveUserDetails() async {
    FirebaseUser currentUser = await _auth.getCurrentUser();
    User user = User(uid: currentUser.uid);
    setState(() {
      _user = user;
    });
    _future = _auth.retreiveUserPhotos(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              SizedBox(height: 20.0),
              RaisedButton(
                color: Colors.grey[200],
                child: Text("Edit profile"),
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
                       )
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
    );
  }
}
