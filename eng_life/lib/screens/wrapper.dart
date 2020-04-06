import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/authenticate/authenticate.dart';
import 'package:eng_life/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user != null)
      print("PRINTING FROM WRAPPER${user.uid}");

    //return either Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    }
    else {
      return Home();
    }
  }
}
