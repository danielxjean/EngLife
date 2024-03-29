import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/wrapper.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return AuthInfo(
      authService: authService,
      child: StreamProvider<User>.value(
        value: authService.user,
        child: MaterialApp(
          home: Wrapper(),
        ),
      ),
    );
  }
}