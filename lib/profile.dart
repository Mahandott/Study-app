import 'package:flutter/material.dart';
import 'state.dart';
import 'onboarding.dart' show schoolIcon;
import 'shell.dart';

class ProfilePage extends StatelessWidget {
  final AppState state;
  const ProfilePage({super.key, required this.state});

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(k, style: const TextStyle(color: Colors.black54))),
            Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeUp(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFDCE8FF),
                    child: Icon(schoolIcon(state.schoolType), size: 34, color: const Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${state.schoolType} · پایه ${state.grade} · ${state.field}',
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeUp(
          order: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('استادی کوین', faDigits(state.coins)),
                  const Divider(height: 1),
                  _row('مجموع مطالعه', fmtHM(state.totalSeconds)),
                  const Divider(height: 1),
                  _row('میانگین روزانه', '${faDigits(state.avgHoursPerDay.toStringAsFixed(1))} ساعت'),
                  const Divider(height: 1),
                  _row('روزشمار کنکور', '${faDigits(state.konkurDaysLeft)} روز'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeUp(
          order: 2,
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: const Text('پاک کردن همه اطلاعات؟'),
                    content: const Text('این کار قابل بازگشت نیست.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لغو')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('پاک کن')),
                    ],
                  ),
                ),
              );
              if (ok == true) state.resetAll();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('ریست اطلاعات'),
          ),
        ),
      ],
    );
  }
}
