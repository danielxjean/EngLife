import 'package:eng_life/screens/home/home_screens/add_photo.dart';
import 'package:eng_life/screens/home/home_screens/feed.dart';
import 'package:eng_life/screens/home/home_screens/post_detail.dart';
import 'package:eng_life/screens/home/home_screens/profile.dart';
import 'package:eng_life/screens/home/home_screens/search.dart';
import 'package:eng_life/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  static final AuthService _auth = AuthService();

  int _page= 0;
  PageController pageController;

  onNavigationItemTapped(int page) {
    pageController.jumpToPage(page);
  }

  onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: PageView(
        children: <Widget>[
          Container(
            color: Colors.grey[100],
            child: Feed(),
          ),
          Container(
            color: Colors.grey[100],
            child: AddPhoto(),
          ),
          Container(
            color: Colors.grey[100],
            child: Search(pageController: pageController),
          ),
          Container(
            color: Colors.grey[100],
            child: Profile(),
          )
        ],
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
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
        currentIndex: _page,
        onTap: onNavigationItemTapped
      ),
    );
  }
}