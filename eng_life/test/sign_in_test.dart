import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/authenticate/sign_in.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';


class MockAuthService extends Mock implements AuthService{}

void main() {
  Widget makeTestableWidget({Widget childHome, AuthService authService}){
    return AuthInfo(
      authService: authService,
      child: StreamProvider<User>.value(
        value: authService.user,
        child: MaterialApp(
          home: childHome,
        ),
      ),
    );
  }
  group('Sign in', (){
    //region 'SignIn: empty email and password, does not sign in'
    testWidgets('SignIn: empty email and password, does not sign in', (WidgetTester tester) async {
      //1. Create
      MockAuthService mockAuthService = MockAuthService();
      SignIn signInPage = SignIn();

      //2. Stub
      //No stub needed.

      //3. Act
      //Load page
      await tester.pumpWidget(makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
      //Tap sign-in button
      await tester.tap(find.byKey(Key('signIn')));

      //4.Verify
      //No attempt to sign in should be made
      verifyNever(mockAuthService.signInWithEmailAndPassword(any, any));
    });//testWidgets
    //endregion
    //region 'SignIn: empty email and non-empty password, does not sign in'
    testWidgets('SignIn: empty email and non-empty password, does not sign in', (WidgetTester tester) async {
      //1. Create
      MockAuthService mockAuthService = MockAuthService();
      SignIn signInPage = SignIn();

      //2. Stub
      //No stub needed.

      //3. Act
      //Load page
      await tester.pumpWidget(makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
      //Enter password
      Finder passwordField = find.byKey(Key('password'));

      String password = 'password';

      await tester.enterText(passwordField, password);
      //Tap sign-in button
      await tester.tap(find.byKey(Key('signIn')));

      //4.Verify
      //No attempt to sign in should be made
      verifyNever(mockAuthService.signInWithEmailAndPassword(any, password));
    });//testWidgets
    //endregion
    //region 'SignIn: non-empty email and empty password, does not sign in'
    testWidgets('SignIn: non-empty email and empty password, does not sign in', (WidgetTester tester) async {
      //1. Create
      MockAuthService mockAuthService = MockAuthService();
      SignIn signInPage = SignIn();

      //2. Stub
      //No stub needed.

      //3. Act
      //Load page
      await tester.pumpWidget(makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
      //Enter email
      Finder emailField = find.byKey(Key('email'));

      String email = 'email@email';

      await tester.enterText(emailField, email);
      //Tap sign-in button
      await tester.tap(find.byKey(Key('signIn')));

      //4.Verify
      //No attempt to sign in should be made
      verifyNever(mockAuthService.signInWithEmailAndPassword(email, any));
    });//testWidgets
    //endregion
    //region 'SignIn: non-empty email and password, invalid password length, does not sign in'
    testWidgets('SignIn: non-empty email and password, invalid password length, does not sign in', (WidgetTester tester) async {
      //1. Create Mocks
      MockAuthService mockAuthService = MockAuthService();
      SignIn signInPage = SignIn();

      //2. Stub
      //No stub needed.

      //3. Act
      //Load page
      await tester.pumpWidget(makeTestableWidget(childHome: signInPage, authService:  mockAuthService));

      //Enter email and password
      Finder emailField = find.byKey(Key('email'));
      Finder passwordField = find.byKey(Key('password'));

      String email = 'email@email';
      String password = 'passw';  //password of length <6

      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign-in button
      await tester.tap(find.byKey(Key('signIn')));

      //4. Verify
      //No attempt to sign in should be made
      verifyNever(mockAuthService.signInWithEmailAndPassword(any, password));
    });//testWidgets
    //endregion
    //region 'SignIn: non-empty email and password, invalid user, does not sign in'
    testWidgets('SignIn: non-empty email and password, invalid user, does not sign in', (WidgetTester tester) async {
      //1. Create Mocks
      MockAuthService mockAuthService = MockAuthService();
      SignIn signInPage = SignIn();

      //2. Stub
      //have the sign in method return an error code for invalid user.
      when(mockAuthService.signInWithEmailAndPassword(any, any)).thenAnswer((_) => Future(() => 3));

      //3. Act
      //Load page
      await tester.pumpWidget(makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
      //Enter email and password
      Finder emailField = find.byKey(Key('email'));
      Finder passwordField = find.byKey(Key('password'));

      String email = 'email@email';
      String password = 'password';

      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign-in button
      await tester.tap(find.byKey(Key('signIn')));

      //Wait to allow for futures to complete. Otherwise, flutter test will throw an error about a timer still pending after disposing the widget tree.
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      //4. Verify
      final errorFinder = find.text('No user exists with entered email.');

      //attempt to sign in should be made, but an error message should be given.
      verify(mockAuthService.signInWithEmailAndPassword(email, password));
      expect(errorFinder, findsOneWidget);
    });//testWidgets
    //endregion
    //region 'SignIn: non-empty email and password, valid user, does sign in'
    testWidgets('SignIn: non-empty email and password, valid user, does sign in', (WidgetTester tester) async {
      //1. Create Mocks
      MockAuthService mockAuthService = MockAuthService();
      SignIn signInPage = SignIn();

      //2. Stub
      //have the sign in method not return an error code for invalid user.
      when(mockAuthService.signInWithEmailAndPassword(any, any)).thenAnswer((_) => Future(() =>  User()));   //return an user

      //3. Act
      //Load page
      await tester.pumpWidget(makeTestableWidget(childHome: signInPage, authService:  mockAuthService));

      //Enter email and password
      Finder emailField = find.byKey(Key('email'));
      Finder passwordField = find.byKey(Key('password'));

      String email = 'email@email';
      String password = 'password';

      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign-in button
      await tester.tap(find.byKey(Key('signIn')));

      //Wait to allow for futures to complete. Otherwise, flutter test will throw an error about a timer still pending after disposing the widget tree.
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      //4. Verify
      final errorFinder = find.text('Password entered is incorrect.');
      final errorFinder2 = find.text('The email address is badly formatted.');
      final errorFinder3 = find.text('No user exists with entered email.');

      //attempt to sign in should be made, and no error message should be given.
      verify(mockAuthService.signInWithEmailAndPassword(email, password));
      expect(errorFinder, findsNothing);
      expect(errorFinder2, findsNothing);
      expect(errorFinder3, findsNothing);
    });//testWidgets
    //endregion
  });//group

 group('Unit Tests', (){
   //TODO: implement unit tests for SignIn page
 });//group
}