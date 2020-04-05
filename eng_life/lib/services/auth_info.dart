import 'package:flutter/material.dart';
import 'package:eng_life/services/auth.dart';

class AuthInfo extends InheritedWidget{
  AuthInfo({Key key, Widget child, AuthService authService}) : authService = authService ?? AuthService(), super(key: key, child: child);
  final AuthService authService;

  @override
  bool updateShouldNotify(AuthInfo oldWidget) => oldWidget.authService != authService;

  /// Not to be called inside initState(). Use the following line instead:
  ///
  ///   final AuthService _auth = context.findAncestorWidgetOfExactType<AuthInfo>().authService;
  ///
  /// See documentation on initState for more information.
  static AuthInfo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AuthInfo>();
}

