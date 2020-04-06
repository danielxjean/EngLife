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
    if (page == 0)
      return SignIn(toggleView: toggleView);
    else if (page == 1)
      return Register(toggleView: toggleView);
    else if (page == 2)
      return RegisterPage(toggleView: toggleView);
    else
      print('ERROR: It did not toggle as expected');
  }
  }
