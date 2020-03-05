import 'dart:io';

import 'package:eng_life/services/auth.dart';
import 'package:flutter/material.dart';

class EditNewPhoto extends StatefulWidget {

  File imageSelected;

  EditNewPhoto({this.imageSelected});

  @override
  _EditNewPhotoState createState() => _EditNewPhotoState();
}

class _EditNewPhotoState extends State<EditNewPhoto> {

  final AuthService _auth = AuthService();

  String caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("Edit Photo"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(widget.imageSelected),
                    fit: BoxFit.cover,
                  )
                ),
                height: 400,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Caption'
                )
              ),
              SizedBox(height: 20),
              RaisedButton(
                child: Text(
                  "Upload Photo",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                onPressed: () {
                  /*
                  if (_imageSelected != null) {
                    uploadPicture();
                  }
                  else {

                  }
                  */
                },
              )
            ],
          ),
        ),
      )
    );
  }
}
