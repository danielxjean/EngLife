import 'package:eng_life/screens/authenticate/authenticate.dart';
import 'package:eng_life/screens/authenticate/register.dart';
import 'package:eng_life/screens/authenticate/sign_in.dart';
import 'package:eng_life/services/auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'test_helper.dart';

class MockAuthService extends Mock implements AuthService{}

void main() {

  //TODO: write tests for Authenticate
  // - test for toggle view by tapping the appropriate button.

  group('Authenticater', (){
    testWidgets('Authenticate: loads SignIn, toggles back and forth with Register pages', (WidgetTester tester) async {
      //region Test for Authenticate
      //region 1. Create Mocks
      MockAuthService mockAuthService = MockAuthService();
      Authenticate authenticatePage = Authenticate();
      //endregion

      //region 2. Stub
      //No stub needed.
      //endregion

      //region 3. Act and 4. Verify
      //Load page
      await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: authenticatePage, authService: mockAuthService));

      //Verify SignIn displayed.
      final Finder signInFinder = find.byType(SignIn);
      final Finder registerFinder = find.byType(Register);
      final Finder toggleButton = find.byKey(Key('toggle'));

      expect(signInFinder, findsOneWidget);
      expect(registerFinder, findsNothing);

      //Tap on toggle
      await tester.tap(toggleButton);
      await tester.pump();


      //Verify Register displayed
      expect(signInFinder, findsNothing);
      expect(registerFinder, findsOneWidget);

      //Tap on toggle
      await tester.tap(toggleButton);
      await tester.pump();

      //Verify SignIn displayed
      expect(signInFinder, findsOneWidget);
      expect(registerFinder, findsNothing);

      expect(toggleButton, findsOneWidget);    //The button should still be present. Implicitly tested previously by actually tapping it.
      //endregion
      //endregion
    });
    testWidgets('Authenticate: text fields should reset on toggles', (WidgetTester tester) async {
      //region Test for Authenticate
      //region 1. Create Mocks
      MockAuthService mockAuthService = MockAuthService();
      Authenticate authenticatePage = Authenticate();
      //endregion

      //region 2. Stub
      //No stub needed.
      //endregion

      //region 3. Act and 4. Verify
      final Finder toggleButton = find.byKey(Key('toggle'));

      final Finder nameField = find.byKey(Key('name'));
      final Finder emailField = find.byKey(Key('email'));
      final Finder passwordField = find.byKey(Key('password'));
      final Finder password2Field = find.byKey(Key('password2'));
      List<Finder> fieldsInRegister = [nameField, emailField, passwordField, password2Field];
      List<Finder> fieldsInSignIn = [emailField, passwordField];

      //Load page
      await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: authenticatePage, authService: mockAuthService));

      //Verify SignIn empty fields.
      TestHelper.expectExist(fieldsInSignIn);
      TestHelper.expectEmptyText(fieldsInSignIn);

      //Enter Text and Tap on toggle
      await tester.enterText(emailField, 'email');
      await tester.enterText(passwordField, 'password');

      await tester.tap(toggleButton);
      await tester.pump();

      //Verify Register empty fields.
      TestHelper.expectExist(fieldsInRegister);
      TestHelper.expectEmptyText(fieldsInRegister);

      //Enter Text and Tap on toggle
      await tester.enterText(nameField, 'name');
      await tester.enterText(emailField, 'email');
      await tester.enterText(passwordField, 'password');
      await tester.enterText(password2Field, 'password2');
      await tester.tap(toggleButton);
      await tester.pump();

      //Verify SignIn empty fields.
      TestHelper.expectExist(fieldsInSignIn);
      TestHelper.expectEmptyText(fieldsInSignIn);
      //endregion
      //endregion
    });
  });//group

  group('Unit Tests', (){
    //TODO: add unit tests.
  });//group
}
