import 'dart:async';

import 'package:eng_life/models/customPost.dart';
import 'package:eng_life/services/auth.dart';
import 'package:eng_life/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'test_helper.dart';

class MockAuthService extends Mock implements AuthService{}

void main() {
  group('Authenticater', (){
    //Since the user doesn't interact with this widget directly, and this widget is very straightforward, there aren't any negative tests.
    group('Positive Testing', (){
      testWidgets('CustomPost: like button toggles', (WidgetTester tester) async {
        //region Test for CustomPost
        //region 1. Create Mocks and pages

        DocumentSnapshot postSnapshot = TestHelper.postDocumentSnapshot;
        User testUser = TestHelper.user;
        testUser.uid = '1';
        bool callDialog = false;
        bool callHomePage = false;
        final Function changeHomePage = () { callHomePage = true; return;};
        final Function createDeleteConfirmationDialog = () { callDialog = true; return;};


        MockAuthService mockAuthService = MockAuthService();
        CustomPost customPost = CustomPost(documentSnapshot: postSnapshot, currentUser: testUser, createDeleteConfirmationDialog: createDeleteConfirmationDialog, changeHomePage: changeHomePage, displayedOnFeed: false);
        //endregion

        //region 2. Stub
        Completer completer = Completer<Null>();
        Completer like = Completer<Null>();
        when(mockAuthService.checkIfCurrentUserLiked(any, any)).thenAnswer((_) => Future(() {like.complete(); return false;}));
        when(mockAuthService.likePost(any, any, any, any)).thenAnswer((_) => Future(() {completer.complete();}));
        when(mockAuthService.refreshSnapshotInfo(postSnapshot)).thenAnswer((_) => Future(() => postSnapshot));
        //endregion

        //region 3. Act and 4. Verify
        //Load page
        await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: customPost, authService: mockAuthService));
        //print('load');

        //Verify CustomPost displayed.
        final Finder displayName = find.byKey(Key('displayName'));
        final Finder liked = find.byKey(Key('liked'));
        final Finder unliked = find.byKey(Key('unliked'));
        final Finder commentButton = find.byKey(Key('comment'));
        final Finder image = find.byKey(Key('image'));
        final Finder delete = find.byKey(Key('delete'));
        List<Finder> customPostDisplay = [displayName, commentButton, image];

        await tester.pump(Duration(seconds: 3));
        await like.future;
        //print(like.isCompleted);
        //expect unliked post.
        TestHelper.expectExist(customPostDisplay);
        expect(liked, findsNothing);
        expect(unliked, findsOneWidget);
        //print('load2');

       // print(completer.isCompleted);
        //Tap on like button
        await tester.tap(unliked);
        await tester.pump();
        await tester.pump(Duration(seconds: 3));

        await completer.future;
        //print(completer.isCompleted);

        //print('load3');
        //Verify liked post displayed
        TestHelper.expectExist(customPostDisplay);
        expect(liked, findsOneWidget);
        expect(unliked, findsNothing);

        //print('load4');
        //Tap on like button
        //print(completer.isCompleted);
        completer = Completer<Null>();
        //print(completer.isCompleted);
        await tester.tap(liked);
        await tester.pump();
        await tester.pump(Duration(seconds: 3));
        await completer.future;
        //print(completer.isCompleted);
        //print('load5');
        //Verify liked post displayed
        TestHelper.expectExist(customPostDisplay);
        expect(liked, findsNothing);
        expect(unliked, findsOneWidget);
        //endregion
        //endregion
      });//testWidgets
      testWidgets('CustomPost: like button calls auth methods', (WidgetTester tester) async {
        //region Test for CustomPost
        //region 1. Create Mocks and pages

        DocumentSnapshot postSnapshot = TestHelper.postDocumentSnapshot;
        User testUser = TestHelper.user;
        testUser.uid = '1';
        bool callDialog = false;
        bool callHomePage = false;
        final Function changeHomePage = () { callHomePage = true; return;};
        final Function createDeleteConfirmationDialog = () { callDialog = true; return;};

        MockAuthService mockAuthService = MockAuthService();
        CustomPost customPost = CustomPost(documentSnapshot: postSnapshot, currentUser: testUser, createDeleteConfirmationDialog: createDeleteConfirmationDialog, changeHomePage: changeHomePage, displayedOnFeed: false);
        //endregion

        //region 2. Stub
        Completer completer = Completer<Null>();
        Completer like = Completer<Null>();
        when(mockAuthService.checkIfCurrentUserLiked(any, any)).thenAnswer((_) => Future(() { like.complete(); return false;}));
        when(mockAuthService.likePost(any, any, any, any)).thenAnswer((_) => Future(() {completer.complete();}));
        when(mockAuthService.refreshSnapshotInfo(postSnapshot)).thenAnswer((_) => Future(() => postSnapshot));
        //endregion

        //region 3. Act and 4. Verify
        //Load page
        await tester.pumpWidget(TestHelper.makeTestableWidget(childHome: customPost, authService: mockAuthService));

        //Verify CustomPost displayed.
        final Finder displayName = find.byKey(Key('displayName'));
        final Finder liked = find.byKey(Key('liked'));
        final Finder unliked = find.byKey(Key('unliked'));
        final Finder commentButton = find.byKey(Key('comment'));
        final Finder image = find.byKey(Key('image'));
        final Finder delete = find.byKey(Key('delete'));
        List<Finder> customPostDisplay = [displayName, commentButton, image];

        await tester.pump(Duration(seconds: 3));
        await like.future;
        //expect unliked post.
        TestHelper.expectExist(customPostDisplay);
        expect(liked, findsNothing);
        expect(unliked, findsOneWidget);

        //Tap on like button
        await tester.tap(unliked);
        await tester.pump();
        await tester.pump(Duration(seconds: 3));

        await completer.future;

        //Verify liked post
        TestHelper.expectExist(customPostDisplay);
        expect(liked, findsOneWidget);
        expect(unliked, findsNothing);
        verify(mockAuthService.likePost(any, any, any, true)).called(1);
        verifyNever(mockAuthService.likePost(any, any, any, false));

        //Tap on like button
        completer = Completer<Null>();
        await tester.tap(liked);
        await tester.pump();
        await tester.pump(Duration(seconds: 3));
        await completer.future;
        //Verify unliked post
        TestHelper.expectExist(customPostDisplay);
        expect(liked, findsNothing);
        expect(unliked, findsOneWidget);
        verifyNever(mockAuthService.likePost(any, any, any, true));
        verify(mockAuthService.likePost(any, any, any, false)).called(1);
        //endregion
        //endregion
      });//testWidgets
    });//group
  });//group
  group('Unit Tests', (){
    //TODO: add unit tests.
  });//group
}
