import 'package:eng_life/models/user.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  //text field state
  String displayName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error = '';

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        elevation: 0.0,
        title: Text("Sign up to ENGLife"),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text(
              "Sign in",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  //display name input
                  TextFormField(

                    /*
                    TextFormField for user display name
                     */

                    validator: (val) {
                      if (val.isEmpty) {
                        return "Enter your display name.";
                      }
                      else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: "display name"
                    ),
                    onChanged: (val) {
                      //runs every time the value of the formfield is changed
                      setState(() {
                        displayName = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  //email input
                  TextFormField(

                    /*
                    TextFormField for user email
                     */

                    validator: (val) {
                      if (val.isEmpty) {
                        return "Enter an email.";
                      }
                      else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: "email"
                    ),
                    onChanged: (val) {
                      //runs every time the value of the formfield is changed
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  //password input
                  TextFormField(

                    /*
                    TextFormField for user password
                     */

                    validator: (val) {
                      if (val.length < 6)
                        return "Enter a password 6+ characters long.";
                      else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.security),
                        labelText: "password"
                    ),
                    obscureText: true,
                    onChanged: (val) {
                      //runs every time the value of the formfield is changed
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  //confirm password input
                  TextFormField(

                    /*
                    TextFormField for user confirmed password
                     */

                    validator: (val) {
                      if (val != password) {
                        return "Passwords must match.";
                      }
                      else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                        icon: Icon(Icons.security),
                        labelText: "confirm password"
                    ),
                    obscureText: true,
                    onChanged: (val) {
                      //runs every time the value of the formfield is changed
                      setState(() {
                        confirmPassword = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    color: Colors.red[900],
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      //sign in, may take some time therefore async function
                      if (_formKey.currentState.validate()) {

                        setState(() {
                          loading = true;
                        });

                        dynamic result = await _auth.registerWithEmailAndPassword(email, password, displayName);
                        if (result == 1) {
                          setState(() {
                            error = "The email address is badly formatted.";
                            loading = false;
                          });
                        }
                        else if (result == 2) {
                          setState(() {
                            error = "The email address is already in use by another account.";
                            loading = false;
                          });
                        }
                        else {
                          setState(() {
                            error = "Something went wrong, incorrect email or password.";
                            loading = false;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red[900], fontSize: 14.0),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
