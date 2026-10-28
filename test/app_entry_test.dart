import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('المرحلة 1: فتح التطبيق يفتح لوحة الإدارة مباشرة بلا شاشة بداية',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LifeApp());
    await tester.pumpAndSettle();
    expect(find.text('تقدم أسبوعا ⏭️'), findsOneWidget);
    expect(find.text('ابدأ شركة جديدة 🚀'), findsNothing);
    expect(find.text('لوحة الإدارة الجديدة 📊'), findsNothing);
  });

  testWidgets('المرحلة 1: حفظ إدارة قديم بحقول ناقصة يُستأنف دون كسر',
      (tester) async {
    // حفظ من صيغة أقدم: أسبوع ونقد فقط، بلا حقول الأنظمة الأحدث.
    SharedPreferences.setMockInitialValues({
      'ai_management_v1': jsonEncode({'week': 7, 'cash': 9999}),
    });
    await tester.pumpWidget(const LifeApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('تم استئناف إدارة محفوظة'), findsOneWidget);
    expect(find.text('الأسبوع 7'), findsOneWidget);
    expect(find.text('النقد: 9999'), findsOneWidget);
    await tester.tap(find.text('تقدم أسبوعا ⏭️'));
    await tester.pumpAndSettle();
    expect(find.text('الأسبوع 8'), findsOneWidget);
  });
}
