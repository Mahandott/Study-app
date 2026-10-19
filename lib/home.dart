import 'package:flutter/material.dart';
import 'state.dart';
import 'shell.dart';

class HomePage extends StatelessWidget {
  final AppState state;
  final VoidCallback goToStudy;
  const HomePage({super.key, required this.state, required this.goToStudy});

  @override
  Widget build(BuildContext context) {
    final week = state.lastDays(7);
    final maxV = week.fold<int>(1, (a, b) => b > a ? b : a);
    final doneGoals = state.goals.where((g) => g.done).length;
    const dayNames = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeUp(
          child: Text('سلام، ${state.name} 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        FadeUp(
          order: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('روزشمار کنکور', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('${faDigits(state.konkurDaysLeft)} روز',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                FilledButton.tonal(onPressed: goToStudy, child: const Text('شروع مطالعه')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeUp(
          order: 2,
          child: Row(
            children: [
              Expanded(child: _stat('امروز', fmtHM(state.todaySeconds), Icons.today)),
              const SizedBox(width: 12),
              Expanded(child: _stat('میانگین روزانه', '${faDigits(state.avgHoursPerDay.toStringAsFixed(1))} ساعت', Icons.insights)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeUp(
          order: 3,
          child: Row(
            children: [
              Expanded(child: _stat('استادی کوین', faDigits(state.coins), Icons.monetization_on)),
              const SizedBox(width: 12),
              Expanded(
                child: _stat(
                  'اهداف',
                  state.goals.isEmpty ? '—' : '${faDigits(doneGoals)} از ${faDigits(state.goals.length)}',
                  Icons.flag,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeUp(
          order: 4,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('۷ روز اخیر', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: week[i] / maxV),
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeOutCubic,
                                  builder: (c, v, _) => Container(
                                    width: 18,
                                    height: 4 + 80 * v,
                                    decoration: BoxDecoration(
                                      color: i == 6 ? const Color(0xFF2563EB) : const Color(0xFFBFD3FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(dayNames[(now.subtract(Duration(days: 6 - i)).weekday + 1) % 7],
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2563EB)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
