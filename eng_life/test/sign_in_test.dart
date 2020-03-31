import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/authenticate/sign_in.dart';
import 'package:eng_life/services/auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'test_helper.dart';


class MockAuthService extends Mock implements AuthService{}

void main() {
  group('Sign in', (){
    group('Sign In with empty fields',(){
      group('Negative Testing', (){
        //region 'SignIn: empty email and password, does not sign in'
        testWidgets('SignIn: empty email and password, does not sign in', (WidgetTester tester) async {
          //1. Create
          MockAuthService mockAuthService = MockAuthService();
          SignIn signInPage = SignIn();

          //2. Stub
          //No stub needed.

          //3. Act
          //Load page
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
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
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
          //Enter password
          final Finder passwordField = find.byKey(Key('password'));

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
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
          //Enter email
          final Finder emailField = find.byKey(Key('email'));

          String email = 'email@email.com';

          await tester.enterText(emailField, email);
          //Tap sign-in button
          await tester.tap(find.byKey(Key('signIn')));

          //4.Verify
          //No attempt to sign in should be made
          verifyNever(mockAuthService.signInWithEmailAndPassword(email, any));
        });//testWidgets
        //endregion
      });//group
      group('Positive Testing', (){
        //region 'SignIn: fields should instantiate as empty'
        testWidgets('SignIn: fields should instantiate as empty', (WidgetTester tester) async {
          //1. Create
          MockAuthService mockAuthService = MockAuthService();
          SignIn signInPage = SignIn();

          //2. Stub
          //No stub needed.

          //3. Act
          //Load page
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
          //Tap sign-in button
          await tester.tap(find.byKey(Key('signIn')));

          //4.Verify
          //Text fields should be empty.
          final Finder emailField = find.byKey(Key('email'));
          final Finder passwordField = find.byKey(Key('password'));
          List<Finder> fields = [emailField, passwordField];

          TestHelper.expectExist(fields);
          TestHelper.expectEmptyText(fields);
        });//testWidgets
        //endregion
      });//group
    });//group
    group('Sign In with non-empty fields',(){
      group('Negative Testing', (){
        //region 'SignIn: non-empty email and password, invalid password length, does not sign in'
        testWidgets('SignIn: non-empty email and password, invalid password length, does not sign in', (WidgetTester tester) async {
          //1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          SignIn signInPage = SignIn();

          //2. Stub
          //No stub needed.

          //3. Act
          //Load page
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));

          //Enter email and password
          final Finder emailField = find.byKey(Key('email'));
          final Finder passwordField = find.byKey(Key('password'));

          String email = 'email@email.com';
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
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));
          //Enter email and password
          final Finder emailField = find.byKey(Key('email'));
          final Finder passwordField = find.byKey(Key('password'));

          String email = 'email@email.com';
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
      });//group
      group('Positive Testing', (){
        //region 'SignIn: non-empty email and password, show text'
        testWidgets('SignIn: non-empty email and password, show text', (WidgetTester tester) async {
          //1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          SignIn signInPage = SignIn();

          //2. Stub
          //No stub needed.

          //3. Act
          //Load page
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));

          //3. Act
          String email = 'email@email.com';
          String password = 'password';

          final Finder emailField = find.byKey(Key('email'));
          final Finder passwordField = find.byKey(Key('password'));

          await tester.enterText(emailField, email);
          await tester.enterText(passwordField, password);

          //4. Verify
          final emailFinder = find.text(email);
          final passwordFinder = find.text(password);

          //There should be text entered.
          expect(emailFinder, findsWidgets);
          expect(passwordFinder, findsWidgets);
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
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: signInPage, authService:  mockAuthService));

          //Enter email and password
          final Finder emailField = find.byKey(Key('email'));
          final Finder passwordField = find.byKey(Key('password'));

          String email = 'email@email.com';
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
    });//group
  });//group

 group('Unit Tests', (){
   //TODO: implement unit tests for SignIn page
 });//group
}
