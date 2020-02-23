import 'package:eng_life/services/auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("Search users page in production")
            ],
          ),
        ),
      ),
    );
  }
}
