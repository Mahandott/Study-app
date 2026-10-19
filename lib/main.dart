import 'package:flutter/material.dart';
import 'state.dart';
import 'onboarding.dart';
import 'shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // به‌جای صفحه خالی، خطا رو روی صفحه نشون بده
  ErrorWidget.builder = (details) => Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(
              'خطا:\n${details.exceptionAsString()}',
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      );

  final state = AppState();
  try {
    await state.load();
  } catch (e) {
    debugPrint('load failed: $e');
  }
  runApp(OstadiApp(state: state));
}

class OstadiApp extends StatelessWidget {
  final AppState state;
  const OstadiApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'استادی',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Vazir',
            colorSchemeSeed: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFFF4F6FA),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE6EAF2)),
              ),
            ),
          ),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: state.onboarded
                ? Shell(key: const ValueKey('shell'), state: state)
                : Onboarding(key: const ValueKey('onb'), state: state),
          ),
        );
      },
    );
  }
}
