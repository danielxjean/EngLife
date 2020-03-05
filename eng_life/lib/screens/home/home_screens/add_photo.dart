import 'dart:io';

import 'package:eng_life/screens/home/home_screens/edit_new_photo.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPhoto extends StatefulWidget {

  @override
  _AddPhotoState createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {

  final _auth = AuthService();

  File _imageSelected;

  Future chooseImageFromGallery() async {

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageSelected = image;
    });

  }

  Future chooseImageFromCamera() async {

    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (image != null){
        _imageSelected = image;
      }
      else
        print("No image selected");
    });

  }

  void uploadPicture() async {

    await _auth.getCurrentUser().then((user) {
      _auth.uploadImageToStorage(_imageSelected).then((url) {
        _auth.addPhotoToDb(url);
      });
    });
    setState(() {
      _imageSelected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: _imageSelected != null ? AspectRatio(
                aspectRatio: 300 / 300,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: FractionalOffset.center,
                      image: FileImage(_imageSelected),
                    )
                  ),
                ),
              ) : SizedBox(height: 300.0),
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text(
                "Choose Photo From Gallery",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              onPressed: () {
                chooseImageFromGallery();
                if (_imageSelected != null) {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => EditNewPhoto(imageSelected: _imageSelected)
                      )
                  );
                }
              },
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text(
                "Take Photo With Camera",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              onPressed: () {
                chooseImageFromCamera();
                if (_imageSelected != null) {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => EditNewPhoto(imageSelected: _imageSelected)
                      )
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
