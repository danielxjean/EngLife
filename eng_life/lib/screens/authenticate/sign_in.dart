import 'package:eng_life/services/auth.dart';
import 'package:eng_life/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        elevation: 0.0,
        title: Text("Sign in to ENGLife"),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text(
              "Register",
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
                  TextFormField(

                    /*
                    TextFormField for user email
                     */

                    validator: (val) {
                      if (val.isEmpty) {
                        return "Enter an email";
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
                  TextFormField(

                    /*
                    TextFormField for user password
                     */

                    validator: (val) {
                      if (val.length < 6)
                        return "Enter a password 6+ characters long";
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
                  RaisedButton(
                    color: Colors.red[900],
                    child: Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      //sign in, may take some time therefore async function
                      if (_formKey.currentState.validate()) {

                        setState(() {
                          loading = true;
                        });

                        dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                        switch (result) {
                          case 1: {
                            //invalid password
                            setState(() {
                              error = "Password entered is incorrect.";
                              loading = false;
                            });
                          }break;
                          case 2: {
                            //badly formatted email
                            setState(() {
                              error = "The email address is badly formatted.";
                              loading = false;
                            });
                          }break;
                          case 3: {
                            //no user with that email
                            setState(() {
                              error = "No user exists with entered email.";
                              loading = false;
                            });
                          }break;
                          case -1: {
                            setState(() {
                              loading = false;
                            });
                          }
                        }
                      }

                    },
                  ),
                  SizedBox(height: 20.0,),
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