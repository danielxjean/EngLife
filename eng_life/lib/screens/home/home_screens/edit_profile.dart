import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final _auth = AuthService();

  User _currentUser;
  Future<User> _currentUserFuture;
  bool _loading = true;

  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  File _imageSelected;
  bool _newProfilePic = false;

  Future chooseImageFromGallery() async {

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(mounted){
      setState(() {
        _imageSelected = image;
        _newProfilePic = true;
      });
    }
  }

  uploadNewInfo() async {
    //Save new picture (if selected)
    //Save display name (whether changed or not)
    //Save bio (whether changed or not)
    Map<String, String> imageURL;

    if (_newProfilePic && _imageSelected != null) {
      imageURL = await _auth.uploadImageToStorage(_imageSelected);
    }

    _auth.updateUserProfileInformation(_currentUser, imageURL, _displayNameController.text, _bioController.text);

  }

  @override
  void initState() {
    super.initState();
    retreiveUserDetails();
  }

  retreiveUserDetails() async {
    User currentUser = await _auth.getCurrentUser();

    if(mounted) {
      setState(() {
        _currentUserFuture = _auth.getCurrentUser();
        _currentUser = currentUser;
        _loading = false;

        _displayNameController.text = currentUser.displayName;
        _bioController.text = currentUser.bio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? Loading() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("Edit Profile"),
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder(
        future: _currentUserFuture,
        builder: ((context, AsyncSnapshot<User> user) {
          if (user.hasData) {
            if (user.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: !(_newProfilePic && _imageSelected != null) ? CachedNetworkImageProvider(
                                user.data.profilePictureUrl
                            ) : FileImage(_imageSelected),
                            radius: 75.0,
                          ),
                          RaisedButton(
                            color: Colors.grey[200],
                            child: Text("Upload new profile picture"),
                            onPressed: () {
                              print("Upload new profile picture");

                              chooseImageFromGallery();

                            },
                          ),
                          SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              "Display name:",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Card(
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: TextField(
                                maxLines: 1,
                                decoration: InputDecoration.collapsed(hintText: null),
                                controller: _displayNameController,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              "Bio:",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Card(
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                              child: TextField(
                                maxLines: 4,
                                decoration: InputDecoration.collapsed(hintText: null),
                                controller: _bioController,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      RaisedButton(
                        child: Text("Save profile"),
                        onPressed: () async {

                          await uploadNewInfo();
                          Navigator.of(context).pop();

                        },
                      )
                    ],
                  ),
                ),
              );
            }
            else {
              return Container();
            }
          }
          else {
            return Container();
          }
        }),
      ),
    );
  }
}
