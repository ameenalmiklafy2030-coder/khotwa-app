import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;
  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dir = await getDatabasesPath();
    final path = join(dir, 'khatwa.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar_emoji TEXT NOT NULL DEFAULT '👤',
        streak_goal INTEGER NOT NULL DEFAULT 30,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        accent_color TEXT NOT NULL DEFAULT '#1D9E75',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        icon TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE completed_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        day INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE(habit_id, year, month, day)
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL UNIQUE,
        enabled INTEGER NOT NULL DEFAULT 0,
        hour INTEGER NOT NULL DEFAULT 8,
        minute INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');

    // فهارس للأداء
    await db.execute(
        'CREATE INDEX idx_completed_habit ON completed_days(habit_id)');
    await db.execute(
        'CREATE INDEX idx_completed_date ON completed_days(year, month, day)');
  }

  // ─────────────────────────────────────────────
  // USER PROFILE
  // ─────────────────────────────────────────────

  Future<UserProfile?> getProfile() async {
    final db = await database;
    final rows = await db.query('user_profile', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // ─────────────────────────────────────────────
  // HABITS
  // ─────────────────────────────────────────────

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final rows = await db.query(
      'habits',
      where: 'is_active = 1',
      orderBy: 'sort_order ASC, created_at ASC',
    );
    if (rows.isEmpty) return [];

    final habits = <Habit>[];
    for (final row in rows) {
      final days = await getCompletedDays(row['id'] as String);
      habits.add(Habit(
        id: row['id'] as String,
        title: row['title'] as String,
        icon: row['icon'] as String,
        completedDays: days,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at'] as int),
      ));
    }
    return habits;
  }

  Future<void> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert('habits', {
      'id': habit.id,
      'title': habit.title,
      'icon': habit.icon,
      'sort_order': 0,
      'created_at': habit.createdAt.millisecondsSinceEpoch,
      'is_active': 1,
    });
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      'habits',
      {'title': habit.title, 'icon': habit.icon},
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(String habitId) async {
    final db = await database;
    // soft delete
    await db.update(
      'habits',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  // ─────────────────────────────────────────────
  // COMPLETED DAYS
  // ─────────────────────────────────────────────

  Future<List<DateTime>> getCompletedDays(String habitId) async {
    final db = await database;
    final rows = await db.query(
      'completed_days',
      columns: ['year', 'month', 'day'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return rows
        .map((r) => DateTime(
            r['year'] as int, r['month'] as int, r['day'] as int))
        .toList();
  }

  Future<void> toggleDay(String habitId, DateTime date) async {
    final db = await database;
    final existing = await db.query(
      'completed_days',
      where: 'habit_id = ? AND year = ? AND month = ? AND day = ?',
      whereArgs: [habitId, date.year, date.month, date.day],
    );
    if (existing.isNotEmpty) {
      await db.delete(
        'completed_days',
        where: 'habit_id = ? AND year = ? AND month = ? AND day = ?',
        whereArgs: [habitId, date.year, date.month, date.day],
      );
    } else {
      await db.insert('completed_days', {
        'habit_id': habitId,
        'year': date.year,
        'month': date.month,
        'day': date.day,
        'completed_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ─────────────────────────────────────────────
  // REMINDERS
  // ─────────────────────────────────────────────

  Future<Map<String, Map<String, dynamic>>> getAllReminders() async {
    final db = await database;
    final rows = await db.query('reminders');
    return {
      for (final r in rows)
        r['habit_id'] as String: {
          'enabled': (r['enabled'] as int) == 1,
          'hour': r['hour'] as int,
          'minute': r['minute'] as int,
        }
    };
  }

  Future<void> saveReminder({
    required String habitId,
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final db = await database;
    await db.insert(
      'reminders',
      {
        'id': habitId,
        'habit_id': habitId,
        'enabled': enabled ? 1 : 0,
        'hour': hour,
        'minute': minute,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─────────────────────────────────────────────
  // نسخ احتياطي وبيانات أولية
  // ─────────────────────────────────────────────

  Future<bool> hasData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM habits'));
    return (count ?? 0) > 0;
  }

  Future<void> seedDefaultHabits() async {
    for (final h in defaultHabits) {
      await insertHabit(h);
    }
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('completed_days');
    await db.delete('reminders');
    await db.delete('habits');
    await db.delete('user_profile');
  }
}
