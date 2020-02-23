import 'package:eng_life/screens/home/home_screens/add_photo.dart';
import 'package:eng_life/screens/home/home_screens/feed.dart';
import 'package:eng_life/screens/home/home_screens/profile.dart';
import 'package:eng_life/screens/home/home_screens/search.dart';
import 'package:eng_life/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  
  final String uid;
  
  Home({this.uid});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  int _selectedIndex = 0;

  List<Widget> _screens = [
    Feed(),
    AddPhoto(),
    Search(),
    Profile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _screens.elementAt(_selectedIndex),
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("ENGLife"),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[100],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            //newsfeed
              icon: Icon(
                Icons.art_track,
                //color: Colors.grey[400],
              ),
              title: Text(
                "Feed",
                //style: TextStyle(color: Colors.grey[900]),
              )
          ),
          BottomNavigationBarItem(
            //add photo
              icon: Icon(
                Icons.add_a_photo,
                //color: Colors.grey[400],
              ),
              title: Text(
                "Add Photo",
                //style: TextStyle(color: Colors.grey[900]),
              )
          ),
          BottomNavigationBarItem(
            //search
              icon: Icon(
                Icons.search,
                //color: Colors.grey[400],
              ),
              title: Text(
                "Search",
                //style: TextStyle(color: Colors.grey[900]),
              )
          ),
          BottomNavigationBarItem(
            //profile
              icon: Icon(
                Icons.person,
                //color: Colors.grey[400],
              ),
              title: Text(
                "Profile",
                //style: TextStyle(color: Colors.grey[900]),
              )
          )
        ],
        unselectedItemColor: Colors.grey[700],
        selectedItemColor: Colors.red[900],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}