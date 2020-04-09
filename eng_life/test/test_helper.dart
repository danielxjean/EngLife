import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/models/user.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/services/auth_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';


class FakeUser {
   final String testUid = 'oHtooOy6euPB2X7ygMXm5GDkI0K2'; //uid of tester.
   final String testEmail = 'test@test.com';              //email of tester.
   User get user =>
      User(
          bio: "",
          uid: testUid,
          email: testEmail,
          displayName: 'Default',
          educationMajor: 'Default',
          numOfPosts: '0',
          numOfFollowers: '0',
          numOfFollowing: '0',
          profilePictureUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png",
          username: "Default",//username input needs to be added to register form, must be unique
          isGroup: false,
          firstLogin: true);
}

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {
  static final String testUid = 'oHtooOy6euPB2X7ygMXm5GDkI0K2'; //uid of tester.
  String documentID;
  Map<String, dynamic> data;

  DocumentSnapshotMock(){
    documentID = 'biMpOZ4NXbz9qQo2ZHVV';
    data = {
      'userId': testUid,
      'postPhotoUrl': 'https://firebasestorage.googleapis.com/v0/b/englife-608ff.appspot.com/o/1586398859979?alt=media&token=39bfb573-5802-4470-b267-d93fc36cef81',
      'postPhotoRef' : '1586398859979',
      'caption' : 'caption',
      'displayName' : 'test',
      'userProfilePictureUrl' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png',
      'numberOfLikes' : '0',
      'timestamp' : Timestamp.now()
    };
  }
}
//Collection of methods to ease testing.
class TestHelper{

  static final String testUid = 'oHtooOy6euPB2X7ygMXm5GDkI0K2'; //uid of tester.

  //Returns a similar widget to the one made in main.dart.
  static Widget makeTestableWidget({Widget childHome, AuthService authService}){
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

  ///Method for registration is too idiosyncratic as is. Maybe leave it in register_test.dart.
  //Loads widget, enters in text fields and presses the register button for the widgetTester.
  Future<void> registrationAct({@required WidgetTester widgetTester, @required AuthService authService, @required Widget registerPage, String name : '', String email : '', String password : '', String password2 : ''}) async{
    assert(widgetTester != null);
    assert(authService != null);
    assert(registerPage != null);
    //region 1. Create Mocks and pages
    //Handled outside of helper method. Since few mocks are needed, they will be passed as parameters.
    //endregion

    //region 2. Stub
    //Handled outside this helper method.
    //endregion

    //region 3. Act
    //Load page
    await widgetTester.pumpWidget(makeTestableWidget(childHome: registerPage, authService: authService));
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

  //expect empty text fields of Finders in input.
  static void expectEmptyText(List<Finder> fields, [Matcher matcher = findsOneWidget]){
    for (Finder field in fields){
      expect(find.descendant(
          of: field, matching: find.text('')
      ), matcher);
    }
  }
  //expect to find Finder.
  static void expectExist(List<Finder> fields, [Matcher matcher = findsOneWidget]){
    for (Finder field in fields){
      expect(field, matcher);
    }
  }

  //get a document snapshot of a post.
  static DocumentSnapshot get postDocumentSnapshot => DocumentSnapshotMock();

  //get a test user.
  static User get user => FakeUser().user;
}