import 'package:flutter/material.dart';
import 'state.dart';

IconData schoolIcon(String type) {
  switch (type) {
    case 'سمپاد':
      return Icons.auto_awesome;
    case 'نمونه دولتی':
      return Icons.workspace_premium;
    case 'دولتی':
      return Icons.account_balance;
    default:
      return Icons.apartment;
  }
}

class Onboarding extends StatefulWidget {
  final AppState state;
  const Onboarding({super.key, required this.state});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int step = 0;
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  String field = 'تجربی';
  String grade = 'دوازدهم';
  String school = 'سمپاد';

  bool get canNext {
    if (step == 0) return nameC.text.trim().length >= 2;
    if (step == 1) return phoneC.text.trim().length >= 10;
    return true;
  }

  void next() {
    if (step < 2) {
      setState(() => step++);
    } else {
      widget.state.completeOnboarding(
        name: nameC.text.trim(),
        phone: phoneC.text.trim(),
        field: field,
        grade: grade,
        schoolType: school,
      );
    }
  }

  Widget chips(List<String> items, String value, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final i in items)
          ChoiceChip(label: Text(i), selected: i == value, onSelected: (_) => setState(() => onTap(i))),
      ],
    );
  }

  Widget stepBody() {
    switch (step) {
      case 0:
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سلام! اسمت چیه؟', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('با اسمت صدات می‌کنیم.'),
            const SizedBox(height: 24),
            TextField(
              controller: nameC,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'نام'),
            ),
          ],
        );
      case 1:
        return SingleChildScrollView(
          key: const ValueKey(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('چند تا اطلاعات دیگه', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: phoneC,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'شماره موبایل'),
              ),
              const SizedBox(height: 20),
              const Text('رشته'),
              const SizedBox(height: 8),
              chips(kFields, field, (v) => field = v),
              const SizedBox(height: 20),
              const Text('پایه'),
              const SizedBox(height: 8),
              chips(kGrades, grade, (v) => grade = v),
            ],
          ),
        );
      default:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نوع مدرسه‌ات؟', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  for (final t in kSchoolTypes)
                    GestureDetector(
                      onTap: () => setState(() => school = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: school == t ? const Color(0xFFDCE8FF) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: school == t ? const Color(0xFF2563EB) : const Color(0xFFE6EAF2),
                            width: school == t ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(schoolIcon(t), size: 44, color: const Color(0xFF2563EB)),
                            const SizedBox(height: 10),
                            Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(value: (step + 1) / 3, borderRadius: BorderRadius.circular(8), minHeight: 8),
              const SizedBox(height: 32),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(-0.08, 0), end: Offset.zero).animate(a),
                      child: c,
                    ),
                  ),
                  child: stepBody(),
                ),
              ),
              Row(
                children: [
                  if (step > 0)
                    TextButton(onPressed: () => setState(() => step--), child: const Text('قبلی')),
                  const Spacer(),
                  FilledButton(
                    onPressed: canNext ? next : null,
                    child: Text(step == 2 ? 'شروع' : 'بعدی'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
