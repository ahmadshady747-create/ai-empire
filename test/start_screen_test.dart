import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_empire/screens/start_screen.dart';

Widget wrap(StartScreen screen) {
  return MaterialApp(
    locale: const Locale('ar'),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: screen,
    ),
  );
}

void main() {
  testWidgets('شاشة البداية: زر بدء واحد واضح وثلاث خطوات موجزة',
      (tester) async {
    await tester.pumpWidget(wrap(StartScreen(
      onStart: () {},
      livesPlayed: 0,
    )));
    expect(find.text('إمبراطورية الذكاء الاصطناعي'), findsOneWidget);
    expect(find.text('ابدأ شركة جديدة 🚀'), findsOneWidget);
    expect(find.text('تبدأ'), findsOneWidget);
    expect(find.text('تدير'), findsOneWidget);
    expect(find.text('تترك إرثا'), findsOneWidget);
    // لا شرح طويل: الفقرة الطويلة والنقاط الست القديمة غائبة.
    expect(find.textContaining('لن تختار أين تولد'), findsNothing);
    expect(find.textContaining('أنظمة عميقة'), findsNothing);
    expect(find.textContaining('سجل رحلة كامل'), findsNothing);
  });

  testWidgets('شاشة البداية: الاستئناف زر ثانوي واضح عند وجود حفظ',
      (tester) async {
    var continued = false;
    await tester.pumpWidget(wrap(StartScreen(
      onStart: () {},
      onContinue: () => continued = true,
      savedName: 'نورون',
      savedAge: 5,
      livesPlayed: 2,
    )));
    final resume = find.text('واصل شركة نورون (عمر 5) ▶️');
    expect(resume, findsOneWidget);
    await tester.ensureVisible(resume);
    await tester.pumpAndSettle();
    await tester.tap(resume);
    expect(continued, isTrue);
    expect(find.text('بنيتَ 2 شركات حتى الآن'), findsOneWidget);
  });
}
