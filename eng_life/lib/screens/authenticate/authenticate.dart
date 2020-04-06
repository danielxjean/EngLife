import 'package:eng_life/screens/authenticate/register.dart';
import 'package:eng_life/screens/authenticate/sign_in.dart';
import 'package:eng_life/screens/authenticate/registerPage.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  int page = 0;

  void toggleView(int number){
    setState(() {
      page = number;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      (page == 0) ? SignIn(toggleView: toggleView) :
      (page == 1) ? Register(toggleView: toggleView):
      (page == 2) ? RegisterPage(toggleView: toggleView) :
      Text('Error: This is an invalid state while authenticating. Please restart and try again.');
  }

}