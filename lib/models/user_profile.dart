import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatarEmoji;
  final int streakGoal;
  final String themeMode; // 'light' | 'dark' | 'system'
  final String accentColor;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarEmoji = '👤',
    this.streakGoal = 30,
    this.themeMode = 'system',
    this.accentColor = '#1D9E75',
    required this.createdAt,
  });

  factory UserProfile.newUser(String name) => UserProfile(
        id: const Uuid().v4(),
        name: name,
        createdAt: DateTime.now(),
      );

  UserProfile copyWith({
    String? name,
    String? avatarEmoji,
    int? streakGoal,
    String? themeMode,
    String? accentColor,
  }) =>
      UserProfile(
        id: id,
        name: name ?? this.name,
        avatarEmoji: avatarEmoji ?? this.avatarEmoji,
        streakGoal: streakGoal ?? this.streakGoal,
        themeMode: themeMode ?? this.themeMode,
        accentColor: accentColor ?? this.accentColor,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatar_emoji': avatarEmoji,
        'streak_goal': streakGoal,
        'theme_mode': themeMode,
        'accent_color': accentColor,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as String,
        name: m['name'] as String,
        avatarEmoji: m['avatar_emoji'] as String? ?? '👤',
        streakGoal: m['streak_goal'] as int? ?? 30,
        themeMode: m['theme_mode'] as String? ?? 'system',
        accentColor: m['accent_color'] as String? ?? '#1D9E75',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            m['created_at'] as int),
      );
}
