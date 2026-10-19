import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kFields = ['تجربی', 'ریاضی', 'انسانی'];
const kGrades = ['دهم', 'یازدهم', 'دوازدهم', 'فارغ‌التحصیل'];
const kSchoolTypes = ['سمپاد', 'نمونه دولتی', 'دولتی', 'غیردولتی'];

const kSubjects = {
  'تجربی': ['ریاضی', 'فیزیک', 'شیمی', 'زیست‌شناسی', 'زمین‌شناسی', 'ادبیات', 'عربی', 'دین و زندگی', 'زبان'],
  'ریاضی': ['ریاضی', 'فیزیک', 'شیمی', 'ادبیات', 'عربی', 'دین و زندگی', 'زبان'],
  'انسانی': ['ریاضی و آمار', 'اقتصاد', 'علوم و فنون ادبی', 'تاریخ', 'جغرافیا', 'جامعه‌شناسی', 'فلسفه و منطق', 'عربی', 'دین و زندگی', 'زبان'],
};

/// هر ۶ دقیقه مطالعه = ۱ استادی کوین (۱۰ کوین در ساعت). قابل تنظیم.
const kSecondsPerCoin = 360;

/// تاریخ تقریبی کنکور ۱۴۰۶ (میلادی). در صورت اعلام تاریخ رسمی عوض شود.
final DateTime kKonkur1406 = DateTime(2027, 6, 18);

String faDigits(Object v) {
  const en = '0123456789';
  const fa = '۰۱۲۳۴۵۶۷۸۹';
  var s = v.toString();
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(en[i], fa[i]);
  }
  return s;
}

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Goal {
  String id;
  String title;
  int priority; // 1 بالا، 2 متوسط، 3 کم
  bool done;
  Goal({required this.id, required this.title, this.priority = 2, this.done = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'priority': priority, 'done': done};
  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
        id: j['id'] as String,
        title: j['title'] as String,
        priority: (j['priority'] as num?)?.toInt() ?? 2,
        done: j['done'] as bool? ?? false,
      );
}

class AppState extends ChangeNotifier {
  late SharedPreferences _p;

  bool onboarded = false;
  String name = '';
  String phone = '';
  String field = 'تجربی';
  String grade = 'دوازدهم';
  String schoolType = 'سمپاد';
  int coins = 0;
  Map<String, int> studySeconds = {};
  Map<String, Map<String, int>> subjectSeconds = {};
  List<Goal> goals = [];

  // تایمر
  bool running = false;
  int sessionSeconds = 0;
  String? subject;
  Timer? _timer;
  int _coinCarry = 0;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    onboarded = _p.getBool('onboarded') ?? false;
    name = _p.getString('name') ?? '';
    phone = _p.getString('phone') ?? '';
    field = _p.getString('field') ?? 'تجربی';
    grade = _p.getString('grade') ?? 'دوازدهم';
    schoolType = _p.getString('schoolType') ?? 'سمپاد';
    coins = _p.getInt('coins') ?? 0;
    _coinCarry = _p.getInt('coinCarry') ?? 0;
    final ss = _p.getString('studySeconds');
    if (ss != null) {
      studySeconds = (jsonDecode(ss) as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt()));
    }
    final sub = _p.getString('subjectSeconds');
    if (sub != null) {
      subjectSeconds = (jsonDecode(sub) as Map<String, dynamic>).map((k, v) =>
          MapEntry(k, (v as Map<String, dynamic>).map((a, b) => MapEntry(a, (b as num).toInt()))));
    }
    final g = _p.getString('goals');
    if (g != null) {
      goals = (jsonDecode(g) as List).map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _save() async {
    await _p.setBool('onboarded', onboarded);
    await _p.setString('name', name);
    await _p.setString('phone', phone);
    await _p.setString('field', field);
    await _p.setString('grade', grade);
    await _p.setString('schoolType', schoolType);
    await _p.setInt('coins', coins);
    await _p.setInt('coinCarry', _coinCarry);
    await _p.setString('studySeconds', jsonEncode(studySeconds));
    await _p.setString('subjectSeconds', jsonEncode(subjectSeconds));
    await _p.setString('goals', jsonEncode(goals.map((e) => e.toJson()).toList()));
  }

  Future<void> completeOnboarding({
    required String name,
    required String phone,
    required String field,
    required String grade,
    required String schoolType,
  }) async {
    this.name = name;
    this.phone = phone;
    this.field = field;
    this.grade = grade;
    this.schoolType = schoolType;
    onboarded = true;
    await _save();
    notifyListeners();
  }

  // ---------- مطالعه ----------
  List<String> get subjects => kSubjects[field] ?? const [];

  void selectSubject(String s) {
    if (running) return;
    subject = s;
    notifyListeners();
  }

  void startTimer() {
    if (running || subject == null) return;
    running = true;
    sessionSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    sessionSeconds++;
    final k = dayKey(DateTime.now());
    studySeconds[k] = (studySeconds[k] ?? 0) + 1;
    final m = subjectSeconds.putIfAbsent(k, () => {});
    m[subject!] = (m[subject!] ?? 0) + 1;
    _coinCarry++;
    if (_coinCarry >= kSecondsPerCoin) {
      _coinCarry = 0;
      coins++;
    }
    if (sessionSeconds % 15 == 0) _save();
    notifyListeners();
  }

  Future<void> stopTimer() async {
    _timer?.cancel();
    running = false;
    await _save();
    notifyListeners();
  }

  int get todaySeconds => studySeconds[dayKey(DateTime.now())] ?? 0;
  int get totalSeconds => studySeconds.values.fold(0, (a, b) => a + b);
  int get studyDays => studySeconds.values.where((v) => v > 0).length;
  double get avgHoursPerDay => studyDays == 0 ? 0 : totalSeconds / studyDays / 3600;

  List<int> lastDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      final d = now.subtract(Duration(days: n - 1 - i));
      return studySeconds[dayKey(d)] ?? 0;
    });
  }

  int get konkurDaysLeft {
    final offset = grade == 'دهم' ? 2 : grade == 'یازدهم' ? 1 : 0;
    final target = DateTime(kKonkur1406.year + offset, kKonkur1406.month, kKonkur1406.day);
    final today = DateTime.now();
    return target.difference(DateTime(today.year, today.month, today.day)).inDays;
  }

  // ---------- اهداف ----------
  void addGoal(String title, int priority) {
    goals.add(Goal(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title, priority: priority));
    goals.sort((a, b) => a.priority.compareTo(b.priority));
    _save();
    notifyListeners();
  }

  void toggleGoal(Goal g) {
    g.done = !g.done;
    _save();
    notifyListeners();
  }

  void removeGoal(Goal g) {
    goals.remove(g);
    _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    _timer?.cancel();
    running = false;
    await _p.clear();
    onboarded = false;
    name = '';
    phone = '';
    coins = 0;
    _coinCarry = 0;
    studySeconds = {};
    subjectSeconds = {};
    goals = [];
    subject = null;
    notifyListeners();
  }
}
