import 'package:flutter/material.dart';
import 'state.dart';

class GoalsPage extends StatelessWidget {
  final AppState state;
  const GoalsPage({super.key, required this.state});

  static const _prioLabels = {1: 'اولویت بالا', 2: 'اولویت متوسط', 3: 'اولویت کم'};
  static const _prioColors = {1: Color(0xFFEF4444), 2: Color(0xFFF59E0B), 3: Color(0xFF10B981)};

  Future<void> _add(BuildContext context) async {
    final c = TextEditingController();
    var prio = 2;
    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            title: const Text('هدف جدید'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'عنوان هدف')),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in [1, 2, 3])
                      ChoiceChip(
                        label: Text(_prioLabels[p]!),
                        selected: prio == p,
                        onSelected: (_) => setS(() => prio = p),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')),
              FilledButton(
                onPressed: () {
                  if (c.text.trim().isNotEmpty) state.addGoal(c.text.trim(), prio);
                  Navigator.pop(ctx);
                },
                child: const Text('افزودن'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            const Text('اهداف ماهانه', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (state.goals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: Text('هنوز هدفی نداری. با دکمه + اولین هدفت رو بساز.')),
              ),
            for (final g in state.goals)
              Dismissible(
                key: ValueKey(g.id),
                onDismissed: (_) => state.removeGoal(g),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_outline),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(value: g.done, onChanged: (_) => state.toggleGoal(g)),
                    title: Text(
                      g.title,
                      style: TextStyle(decoration: g.done ? TextDecoration.lineThrough : null),
                    ),
                    subtitle: Text(_prioLabels[g.priority]!, style: TextStyle(color: _prioColors[g.priority])),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: FloatingActionButton(onPressed: () => _add(context), child: const Icon(Icons.add)),
        ),
      ],
    );
  }
}
