import 'package:flutter/material.dart';
import 'package:eng_life/services/auth.dart';

class AuthInfo extends InheritedWidget{
  AuthInfo({Key key, Widget child, AuthService authService}) : authService = authService ?? AuthService(), super(key: key, child: child);
  final AuthService authService;

  @override
  bool updateShouldNotify(AuthInfo oldWidget) => oldWidget.authService != authService;

  static AuthInfo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AuthInfo>();
}

