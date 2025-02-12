// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:diagnosa_campak/ui/home_screen.dart';
import 'package:diagnosa_campak/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:diagnosa_campak/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('MyApp', () {
    late MockSharedPreferences mockSharedPreferences;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockSecureStorage = MockFlutterSecureStorage();
      when(mockSharedPreferences.getBool('isLoggedIn')).thenReturn(false);
    });
    testWidgets('Initial Screen Test', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(isLoggedIn: false));
      expect(find.byType(LoginScreen), findsOneWidget);
    });
    testWidgets('HomeScreen Test', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(isLoggedIn: true));

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
