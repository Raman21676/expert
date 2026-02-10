// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lingo_native_ai/main.dart';
import 'package:lingo_native_ai/providers/user_provider.dart';
import 'package:lingo_native_ai/providers/chat_provider.dart';
import 'package:lingo_native_ai/providers/language_provider.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const LingoNativeApp(),
      ),
    );

    // Verify that the app launches and shows splash screen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
