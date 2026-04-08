import 'dart:convert';

class Habit {
  final String id;
  final String title;
  final String icon;
  final List<DateTime> completedDays;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    required this.icon,
    this.completedDays = const [],
    required this.createdAt,
  });

  bool isDoneOn(DateTime date) {
    return completedDays.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  int completedInMonth(int year, int month) {
    return completedDays
        .where((d) => d.year == year && d.month == month)
        .length;
  }

  int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  double progressInMonth(int year, int month) {
    final done = completedInMonth(year, month);
    final total = daysInMonth(year, month);
    return done / total;
  }

  Habit copyWith({
    String? id,
    String? title,
    String? icon,
    List<DateTime>? completedDays,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      completedDays: completedDays ?? this.completedDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Habit toggleDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final exists = isDoneOn(normalized);
    final updated = exists
        ? completedDays
            .where(
              (d) =>
                  !(d.year == normalized.year &&
                      d.month == normalized.month &&
                      d.day == normalized.day),
            )
            .toList()
        : [...completedDays, normalized];
    return copyWith(completedDays: updated);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon,
        'completedDays':
            completedDays.map((d) => d.toIso8601String()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        title: json['title'],
        icon: json['icon'],
        completedDays: (json['completedDays'] as List)
            .map((d) => DateTime.parse(d))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );

  static String encodeList(List<Habit> habits) =>
      jsonEncode(habits.map((h) => h.toJson()).toList());

  static List<Habit> decodeList(String data) =>
      (jsonDecode(data) as List).map((h) => Habit.fromJson(h)).toList();
}

final defaultHabits = [
  Habit(
    id: '1',
    title: 'الصلاة في جماعة',
    icon: '🕌',
    createdAt: DateTime.now(),
  ),
  Habit(
    id: '2',
    title: 'قراءة القرآن',
    icon: '📖',
    createdAt: DateTime.now(),
  ),
  Habit(
    id: '3',
    title: 'المشي 30 دقيقة',
    icon: '🚶',
    createdAt: DateTime.now(),
  ),
  Habit(
    id: '4',
    title: 'شرب الماء',
    icon: '💧',
    createdAt: DateTime.now(),
  ),
];
