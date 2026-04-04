import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hacksagon/core/session/user_prefs.dart';
import 'package:hacksagon/main.dart';

void main() {
  testWidgets('AgriSense app builds', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await UserPrefs.instance.init();

    await tester.pumpWidget(const AgriSenseApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
