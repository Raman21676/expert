/// Mistake Model
/// Tracks user mistakes for targeted learning
class Mistake {
  final int? id;
  final String mistakeText;
  final String correction;
  final String? mistakeType; // 'grammar', 'vocabulary', 'pronunciation', 'spelling'
  final int occurrenceCount;
  final int firstMade;
  final int lastMade;
  final bool mastered;

  Mistake({
    this.id,
    required this.mistakeText,
    required this.correction,
    this.mistakeType,
    this.occurrenceCount = 1,
    required this.firstMade,
    required this.lastMade,
    this.mastered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mistake_text': mistakeText,
      'correction': correction,
      'mistake_type': mistakeType,
      'occurrence_count': occurrenceCount,
      'first_made': firstMade,
      'last_made': lastMade,
      'mastered': mastered ? 1 : 0,
    };
  }

  factory Mistake.fromMap(Map<String, dynamic> map) {
    return Mistake(
      id: map['id'] as int?,
      mistakeText: map['mistake_text'] as String,
      correction: map['correction'] as String,
      mistakeType: map['mistake_type'] as String?,
      occurrenceCount: map['occurrence_count'] as int,
      firstMade: map['first_made'] as int,
      lastMade: map['last_made'] as int,
      mastered: map['mastered'] == 1,
    );
  }

  Mistake copyWith({
    int? id,
    String? mistakeText,
    String? correction,
    String? mistakeType,
    int? occurrenceCount,
    int? firstMade,
    int? lastMade,
    bool? mastered,
  }) {
    return Mistake(
      id: id ?? this.id,
      mistakeText: mistakeText ?? this.mistakeText,
      correction: correction ?? this.correction,
      mistakeType: mistakeType ?? this.mistakeType,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      firstMade: firstMade ?? this.firstMade,
      lastMade: lastMade ?? this.lastMade,
      mastered: mastered ?? this.mastered,
    );
  }

  @override
  String toString() {
    return 'Mistake(mistake: $mistakeText, correction: $correction, mastered: $mastered)';
  }
}
