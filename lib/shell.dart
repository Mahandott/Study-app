import 'package:flutter/material.dart';
import 'state.dart';
import 'home.dart';
import 'study.dart';
import 'goals.dart';
import 'profile.dart';

class Shell extends StatefulWidget {
  final AppState state;
  const Shell({super.key, required this.state});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(state: widget.state, goToStudy: () => setState(() => index = 1)),
      StudyPage(state: widget.state),
      GoalsPage(state: widget.state),
      ProfilePage(state: widget.state),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.state,
          builder: (context, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'مطالعه'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'اهداف'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'پروفایل'),
        ],
      ),
    );
  }
}

/// ورودی نرم برای کارت‌ها
class FadeUp extends StatelessWidget {
  final Widget child;
  final int order;
  const FadeUp({super.key, required this.child, this.order = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + order * 90),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

String fmtHM(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h == 0) return '${faDigits(m)} دقیقه';
  return '${faDigits(h)} ساعت و ${faDigits(m)} دقیقه';
}
