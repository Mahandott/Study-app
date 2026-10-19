import 'package:flutter/material.dart';
import 'state.dart';
import 'shell.dart';

class StudyPage extends StatelessWidget {
  final AppState state;
  const StudyPage({super.key, required this.state});

  String _clock(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return faDigits('${two(h)}:${two(m)}:${two(sec)}');
  }

  @override
  Widget build(BuildContext context) {
    final today = state.subjectSeconds[dayKey(DateTime.now())] ?? {};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('استادی‌تریکر', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: state.running ? const Color(0xFF2563EB) : const Color(0xFFE6EAF2),
                width: state.running ? 8 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(state.running ? 0.25 : 0),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_clock(state.sessionSeconds),
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(state.subject ?? 'یک درس انتخاب کن',
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: state.running
                ? state.stopTimer
                : (state.subject == null ? null : state.startTimer),
            icon: Icon(state.running ? Icons.stop : Icons.play_arrow),
            label: Text(state.running ? 'پایان' : 'شروع'),
          ),
        ),
        const SizedBox(height: 24),
        const Text('درس', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in state.subjects)
              ChoiceChip(
                label: Text(s),
                selected: state.subject == s,
                onSelected: state.running ? null : (_) => state.selectSubject(s),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('مطالعه امروز', style: TextStyle(fontWeight: FontWeight.bold))),
                    Text(fmtHM(state.todaySeconds)),
                  ],
                ),
                const SizedBox(height: 8),
                if (today.isEmpty) const Text('هنوز چیزی ثبت نشده.', style: TextStyle(color: Colors.black54)),
                for (final e in today.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(e.key)),
                        Text(fmtHM(e.value), style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('هر ${faDigits(kSecondsPerCoin ~/ 60)} دقیقه مطالعه = ۱ استادی کوین',
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 12)),
      ],
    );
  }
}
