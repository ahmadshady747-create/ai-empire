import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/management_screen.dart';
import 'theme/empire_theme.dart';

void main() {
  runApp(const LifeApp());
}

/// التطبيق كله عربي وباتجاه يمين إلى يسار، بهوية داكنة عصرية.
/// الحفظ محلي فقط عبر shared_preferences، ولا يحتاج إنترنت.
class LifeApp extends StatelessWidget {
  const LifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إمبراطورية الذكاء الاصطناعي',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildEmpireTheme(),
      home: const ManagementScreen(),
    );
  }
}
