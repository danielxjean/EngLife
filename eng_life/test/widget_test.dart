// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eng_life/main.dart';
import 'package:eng_life/screens/home/home.dart';

void main() {
  test('Initialize Home page', () {
    final page = Home();
    _HomeState homePage = page.createState();

    expect(homePage._page, 0);
  });
}
