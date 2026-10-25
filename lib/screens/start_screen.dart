import 'package:flutter/material.dart';

/// شاشة البداية: تُفهم من أول نظرة، دون شرح طويل.
/// زر بدء واحد واضح، واستئناف ثانوي للشركة المحفوظة، وشريط من ثلاث
/// خطوات يلخّص دورة اللعب كلها: تبدأ، تدير، تترك إرثا.
class StartScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback? onContinue;
  final String? savedName;
  final int? savedAge;
  final int livesPlayed;

  const StartScreen({
    super.key,
    required this.onStart,
    this.onContinue,
    this.savedName,
    this.savedAge,
    required this.livesPlayed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🤖',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  const Text(
                    'إمبراطورية الذكاء الاصطناعي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'من مرآب صغير إلى إمبراطورية. قراراتك أنت.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 1.7),
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    children: [
                      Expanded(child: _Step(icon: '🚀', label: 'تبدأ')),
                      SizedBox(width: 8),
                      Text('›', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Expanded(child: _Step(icon: '🧭', label: 'تدير')),
                      SizedBox(width: 8),
                      Text('›', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Expanded(child: _Step(icon: '🏛️', label: 'تترك إرثا')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'كل نموذج له ثمن، وكل شركة تنتهي بسؤال واحد: كيف بنيتها؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.7),
                  ),
                  const SizedBox(height: 36),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('ابدأ شركة جديدة 🚀'),
                  ),
                  if (onContinue != null && savedName != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onContinue,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      child: Text(
                          'واصل شركة $savedName (عمر ${savedAge ?? 0}) ▶️'),
                    ),
                  ],
                  if (livesPlayed > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'بنيتَ $livesPlayed ${livesPlayed == 1 ? 'شركة' : 'شركات'} حتى الآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'لعبة قصصية مجانية، تعمل دون إنترنت، ولا تجمع أي بيانات. أحداث العالم سيناريوهات محاكاة، ليست تنبؤات.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String icon;
  final String label;

  const _Step({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
