import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/management.dart';
import 'package:ai_empire/screens/management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('حفظ من اللوحة بعد تقدم أسبوع يعرض تأكيد حفظ',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
        const MaterialApp(home: ManagementScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تقدم أسبوعا ⏭️'));
    await tester.pumpAndSettle();
    expect(find.text('الأسبوع 2'), findsOneWidget);
    await tester.tap(find.text('حفظ الإدارة'));
    await tester.pumpAndSettle();
    expect(find.textContaining('تم حفظ الإدارة (الأسبوع 2)'),
        findsOneWidget);
  });

  testWidgets('فتح اللوحة مع حفظ موجود يستأنف الأسبوع والنقد المحفوظين',
      (tester) async {
    final saved = ManagementState(week: 5, cash: 4321);
    SharedPreferences.setMockInitialValues({
      'ai_management_v1': jsonEncode(saved.toJson()),
    });
    await tester.pumpWidget(
        const MaterialApp(home: ManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('تم استئناف إدارة محفوظة'), findsOneWidget);
    expect(find.text('الأسبوع 5'), findsOneWidget);
    expect(find.text('النقد: 4321'), findsOneWidget);
  });

  testWidgets('حفظ تالف لا يكسر اللوحة بل يبدأ إدارة جديدة',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'ai_management_v1': 'ليس JSON صالحا',
    });
    await tester.pumpWidget(
        const MaterialApp(home: ManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.text('الأسبوع 1'), findsOneWidget);
    expect(find.text('النقد: 150000'), findsOneWidget);
    expect(find.textContaining('تم استئناف إدارة محفوظة'), findsNothing);
  });
}
