import 'package:eng_life/models/user.dart';
import 'package:eng_life/screens/authenticate/register.dart';
import 'package:eng_life/services/auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'test_helper.dart';

class MockAuthService extends Mock implements AuthService{}

void main() {
  //Loads widget, enters in text fields and presses the register button for the widgetTester.
  Future<void> registrationAct({@required WidgetTester widgetTester, @required AuthService authService, @required Widget registerPage, String name : '', String email : '', String password : '', String password2 : ''}) async{
    assert(widgetTester != null);
    assert(authService != null);
    assert(registerPage != null);
    //region 1. Create Mocks
    //Handled outside of helper method. Since few mocks are needed, they will be passed as parameters.
    //endregion

    //region 2. Stub
    //Handled outside this helper method.
    //endregion

    //region 3. Act
    //Load page
    await widgetTester.pumpWidget(TestHelper.makeTestableWidget(childHome: registerPage, authService: authService));
    //Enter name, email and passwords
    final Finder nameField = find.byKey(Key('name'));
    final Finder emailField = find.byKey(Key('email'));
    final Finder passwordField = find.byKey(Key('password'));
    final Finder password2Field = find.byKey(Key('password2'));

    await widgetTester.enterText(nameField, name);
    await widgetTester.enterText(emailField, email);
    await widgetTester.enterText(passwordField, password);
    await widgetTester.enterText(password2Field, password2);

    //Tap register button
    await widgetTester.tap(find.byKey(Key('register')));
    //endregion

    //region 4. Verify
    //Handled outside this helper method.
    //endregion
  }

  group('Register', (){
    group('Register with empty fields', (){
      group('Negative Testing', (){
        testWidgets('Register: empty name, email, password and password2; does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //No stub needed
          //endregion

          //region 3. Act
          //Load page
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: registerPage, authService:  mockAuthService));
          //Tap register button
          await tester.tap(find.byKey(Key('register')));
          //endregion

          //region 4.Verify
          //No attempt to register should be made
          verifyNever(mockAuthService.registerWithEmailAndPassword(any, any, any));
          //endregion
          //endregion
        });//testWidgets
        testWidgets('Register: empty name; does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //No stub needed
          //endregion

          //region 3. Act
          //String name = 'name';
          String email = 'email@email.com';
          String password = 'password';
          await registrationAct(widgetTester: tester, registerPage: registerPage, authService: mockAuthService,
              //name: name,
              email: email,
              password: password,
              password2: password);
          //endregion

          //region 4. Verify
          //no attempt to register should be made.
          verifyNever(mockAuthService.registerWithEmailAndPassword(email, password, any));
          //endregion
          //endregion
        });//testWidgets
        testWidgets('Register: empty email; does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //No stub needed
          //endregion

          //region 3. Act
          String name = 'name';
          //String email = 'email@email.com';
          String password = 'password';
          await registrationAct(widgetTester: tester, registerPage: registerPage, authService: mockAuthService,
              name: name,
              //email: email,
              password: password,
              password2: password
          );
          //endregion

          //region 4. Verify
          //no attempt to register should be made.
          verifyNever(mockAuthService.registerWithEmailAndPassword(any, password, name));
          //endregion
          //endregion
        });//testWidgets
        testWidgets('Register: empty password; does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //No stub needed
          //endregion

          //region 3. Act
          String name = 'name';
          String email = 'email@email.com';
          String password2 = 'password';
          await registrationAct(widgetTester: tester, registerPage: registerPage, authService: mockAuthService,
              name: name,
              email: email,
              //password: password,
              password2: password2
          );
          //endregion

          //region 4. Verify
          //no attempt to register should be made.
          verifyNever(mockAuthService.registerWithEmailAndPassword(email, any, name));
          //endregion
          //endregion
        });//testWidgets
        testWidgets('Register: empty password2; does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //no stub needed
          //endregion

          //region 3. Act
          String name = 'name';
          String email = 'email@email.com';
          String password = 'password';
          await registrationAct(widgetTester: tester, registerPage: registerPage, authService: mockAuthService,
            name: name,
            email: email,
            password: password,
            //password2: password
          );
          //endregion

          //region 4. Verify
          //no attempt to register should be made.
          verifyNever(mockAuthService.registerWithEmailAndPassword(email, any, name));
          //endregion
          //endregion
        });//testWidgets
      });//group
      group('Positive Testing', (){
        testWidgets('Register: fields should instantiate as empty', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //No stub needed
          //endregion

          //region 3. Act
          //Load page
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: registerPage, authService:  mockAuthService));
          //endregion

          //region 4.Verify
          //Text fields should be empty.
          final Finder nameField = find.byKey(Key('name'));
          final Finder emailField = find.byKey(Key('email'));
          final Finder passwordField = find.byKey(Key('password'));
          final Finder password2Field = find.byKey(Key('password2'));
          List<Finder> fields = [nameField, emailField, passwordField, password2Field];

          TestHelper.expectExist(fields);
          TestHelper.expectEmptyText(fields);
          //endregion
          //endregion
        });//testWidgets
      });//group
    });//group
    group('Register with non-empty fields', (){
      group('Negative Testing', (){
        testWidgets('Register: non-empty name, email, password and password2, non-matching passwords, does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //have the sign in method not return an error code for invalid user.
          //mock function already returns null by default.
          //endregion

          //region 3. Act
          String name = 'name';
          String email = 'email@email.com';
          String password = 'password';
          String password2 = 'password2';
          await registrationAct(widgetTester: tester, authService: mockAuthService, registerPage: registerPage,
              name: name,
              email: email,
              password: password,
              password2: password2
          );
          //endregion

          //region 4. Verify
          //no attempt to register should be made.
          verifyNever(mockAuthService.registerWithEmailAndPassword(email, any, name));
          //endregion
          //endregion
        });//testWidgets
        testWidgets('Register: non-empty name, email, password and password2, invalid passwords, does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //have the sign in method not return an error code for invalid user.
          //mock function already returns null by default.
          //endregion

          //region 3. Act
          String name = 'name';
          String email = 'email@email.com';
          String password = 'passw';    //password length less than 6
          await registrationAct(widgetTester: tester, authService: mockAuthService, registerPage: registerPage,
              name: name,
              email: email,
              password: password,
              password2: password
          );
          //endregion

          //region 4. Verify
          //no attempt to register should be made.
          verifyNever(mockAuthService.registerWithEmailAndPassword(any, any, any));
          //endregion
          //endregion
        });//testWidgets
        testWidgets('Register: non-empty name, email, password and password2, invalid user, does not register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          when(mockAuthService.registerWithEmailAndPassword(any, any, any)).thenAnswer((_) => Future(() => 2));   //return error code on registration attempt
          //endregion

          //region 3. Act
          String name = 'name';
          String email = 'email@email.com';
          String password = 'password';
          await registrationAct(widgetTester: tester, authService: mockAuthService, registerPage: registerPage,
              name: name,
              email: email,
              password: password,
              password2: password
          );
          //Wait to allow for futures to complete. Otherwise, flutter test will throw an error about a timer still pending after disposing the widget tree.
          await tester.pump();
          await tester.pump(const Duration(seconds: 3));
          //endregion

          //region 4. Verify
          final errorFinder = find.text('The email address is already in use by another account.');
          //attempt to register should be made, and an error message should be given.
          verify(mockAuthService.registerWithEmailAndPassword(email, any, name));
          expect(errorFinder, findsOneWidget);
          //endregion
          //endregion
        });//testWidgets
      });//group
      group('Positive Testing', (){
        testWidgets('Register: non-empty name, email, password and password2, show text', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //No stub needed
          //endregion

          //region 3. Act
          //Load page
          await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: registerPage, authService: mockAuthService));
          //Enter name, email and passwords
          String name = 'name';
          String email = 'email@email.com';
          String password = 'password';
          String password2 = 'password2';

          final Finder nameField = find.byKey(Key('name'));
          final Finder emailField = find.byKey(Key('email'));
          final Finder passwordField = find.byKey(Key('password'));
          final Finder password2Field = find.byKey(Key('password2'));

          await tester.enterText(nameField, name);
          await tester.enterText(emailField, email);
          await tester.enterText(passwordField, password);
          await tester.enterText(password2Field, password2);
          //endregion

          //region 4. Verify
          final nameFinder = find.text(name);
          final emailFinder = find.text(email);
          final passwordFinder = find.text(password);
          final password2Finder = find.text(password2);

          //There should be text entered.
          expect(nameFinder, findsWidgets);
          expect(emailFinder, findsWidgets);
          expect(passwordFinder, findsWidgets);
          expect(password2Finder, findsWidgets);
          //endregion
          //endregion
        });//testWidgets
        testWidgets('Register: non-empty name, email, password and password2, valid user, does register', (WidgetTester tester) async {
          //region Test for register
          //region 1. Create Mocks
          MockAuthService mockAuthService = MockAuthService();
          Register registerPage = Register();
          //endregion

          //region 2. Stub
          //Have the sign in method not return an error code for invalid user.
          when(mockAuthService.registerWithEmailAndPassword(any, any, any)).thenAnswer((_) => Future(() =>  User()));   //return an user
          //endregion

          //region 3. Act
          String name = 'name';
          String email = 'email@email.com';
          String password = 'password';
          await registrationAct(widgetTester: tester, registerPage: registerPage, authService: mockAuthService,
              name: name,
              email: email,
              password: password,
              password2: password
          );
          //Wait to allow for futures to complete. Otherwise, flutter test will throw an error about a timer still pending after disposing the widget tree.
          await tester.pump();
          await tester.pump(const Duration(seconds: 3));
          //endregion

          //region 4. Verify
          final errorFinder = find.text('The email address is badly formatted');
          final errorFinder2 = find.text('The email address is already in use by another account.');
          final errorFinder3 = find.text('Something went wrong, incorrect email or password.');

          //attempt to register should be made, and no error message should be given.
          verify(mockAuthService.registerWithEmailAndPassword(email, password, name));
          expect(errorFinder, findsNothing);
          expect(errorFinder2, findsNothing);
          expect(errorFinder3, findsNothing);
          //endregion
          //endregion
        });//testWidgets
      });//group
    });//group
  });//group

  group('Unit Tests', (){
    //TODO: add unit tests.
  });//group
}
