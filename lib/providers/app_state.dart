import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<Habit> _habits = [];
  UserProfile? _profile;
  ThemeMode _themeMode = ThemeMode.system;
  bool _loading = true;
  bool _isFirstLaunch = false;

  List<Habit> get habits => _habits;
  UserProfile? get profile => _profile;
  ThemeMode get themeMode => _themeMode;
  bool get loading => _loading;
  bool get isFirstLaunch => _isFirstLaunch;

  Future<void> init() async {
    _profile = await _db.getProfile();

    // مستخدم جديد = لا ملف شخصي + لا بيانات
    final hasData = await _db.hasData();
    _isFirstLaunch = _profile == null;

    // للمستخدم القديم فقط — نبذر البيانات الافتراضية
    if (!_isFirstLaunch && !hasData) {
      await _db.seedDefaultHabits();
    }

    _habits = await _db.getAllHabits();

    if (_profile != null) {
      _themeMode = _parseThemeMode(_profile!.themeMode);
    }

    _loading = false;
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark':  return ThemeMode.dark;
      default:      return ThemeMode.system;
    }
  }

  // استدعى بعد إنهاء الـ Onboarding
  void completeOnboarding() {
    _isFirstLaunch = false;
    notifyListeners();
  }

  // ── العادات ──

  Future<void> toggleDay(Habit habit, DateTime date) async {
    await _db.toggleDay(habit.id, date);
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx == -1) return;
    final updated = _habits[idx].toggleDay(date);
    _habits = List.from(_habits)..[idx] = updated;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _db.insertHabit(habit);
    _habits = [..._habits, habit];
    notifyListeners();
  }

  Future<void> deleteHabit(String habitId) async {
    await _db.deleteHabit(habitId);
    await NotificationService().cancelHabitReminder(
        _habits.indexWhere((h) => h.id == habitId));
    _habits = _habits.where((h) => h.id != habitId).toList();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) {
      _habits = List.from(_habits)..[idx] = habit;
      notifyListeners();
    }
  }

  // ── الملف الشخصي ──

  Future<void> saveProfile(UserProfile profile) async {
    if (_profile == null) {
      await _db.saveProfile(profile);
    } else {
      await _db.updateProfile(profile);
    }
    _profile = profile;
    _themeMode = _parseThemeMode(profile.themeMode);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(themeMode: mode);
    await saveProfile(updated);
  }

  // ── إعادة ضبط ──

  Future<void> resetAll() async {
    await _db.clearAll();
    _habits = [];
    _profile = null;
    _themeMode = ThemeMode.system;
    _isFirstLaunch = true;
    notifyListeners();
  }
}
