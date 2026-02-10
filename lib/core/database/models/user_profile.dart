/// User Profile Model
/// Stores user preferences and learning statistics
class UserProfile {
  final int? id;
  final String name;
  final String nativeLanguage;
  final String targetLanguage;
  final String proficiencyLevel; // 'beginner', 'intermediate', 'advanced'
  final int learningStreak;
  final int totalLessons;
  final int createdAt;
  final int lastActive;

  UserProfile({
    this.id,
    required this.name,
    required this.nativeLanguage,
    required this.targetLanguage,
    this.proficiencyLevel = 'beginner',
    this.learningStreak = 0,
    this.totalLessons = 0,
    required this.createdAt,
    required this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'native_language': nativeLanguage,
      'target_language': targetLanguage,
      'proficiency_level': proficiencyLevel,
      'learning_streak': learningStreak,
      'total_lessons': totalLessons,
      'created_at': createdAt,
      'last_active': lastActive,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      nativeLanguage: map['native_language'] as String,
      targetLanguage: map['target_language'] as String,
      proficiencyLevel: map['proficiency_level'] as String,
      learningStreak: map['learning_streak'] as int,
      totalLessons: map['total_lessons'] as int,
      createdAt: map['created_at'] as int,
      lastActive: map['last_active'] as int,
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? nativeLanguage,
    String? targetLanguage,
    String? proficiencyLevel,
    int? learningStreak,
    int? totalLessons,
    int? createdAt,
    int? lastActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      learningStreak: learningStreak ?? this.learningStreak,
      totalLessons: totalLessons ?? this.totalLessons,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, native: $nativeLanguage, target: $targetLanguage, level: $proficiencyLevel)';
  }
}
