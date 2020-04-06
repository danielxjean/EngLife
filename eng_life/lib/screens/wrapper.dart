import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/authenticate/authenticate.dart';
import 'package:eng_life/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/screens/authenticate/groupChoiceByUser.dart';
import 'package:eng_life/shared/loading.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  final AuthService _auth = AuthService();
  User currentUser;
  bool _firstVisit = true;

  void toggleView() {
    setState(() {
      retrieveUser();
      print("Refreshing the wrapper");
    });
  }
  Future<void> retrieveUser() async {
    return currentUser = await _auth.getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user != null)
      print("PRINTING FROM WRAPPER ${user.uid}");

    //return either Home or Authenticate widget
    if (user == null) {
      return Authenticate();  // have to insert a page after the user so they can follow some pages
    }
    else {
      return FutureBuilder<void>(
          future: retrieveUser().whenComplete(() => currentUser.firstLogin = _firstVisit),
          builder: (context, AsyncSnapshot<void> snapshot) {
            if (snapshot.hasData) {
              //currentUser ??= user;
              _firstVisit = false;
              print(currentUser.toString());
              if (currentUser.firstLogin && !currentUser.isGroup) {
                print("Hit the clubs page: firstLogin is " + currentUser.firstLogin.toString() + " and isGroup is " + currentUser.isGroup.toString());
                return ClubsPage(userId: currentUser.uid, user: currentUser, toggleView: toggleView);
              }
              else if (!currentUser.firstLogin && !currentUser.isGroup) {
                print("Hit the home page: firstLogin is " + currentUser.firstLogin.toString() + " and isGroup is " + currentUser.isGroup.toString());
                return Home();
              }
              else{
                return Text('Error: Invalid state in wrapper. Please restart and try again.');
              }
            } else {
              return Loading();
            }
          }
      );
    }
    return Loading(); // Just added this
  }
}
