/// Vocabulary Model
/// Tracks words the user is learning
class Vocabulary {
  final int? id;
  final String word;
  final String translation;
  final String language;
  final int proficiency; // 1=new, 2=learning, 3=familiar, 4=proficient, 5=mastered
  final int firstSeen;
  final int lastReviewed;
  final int reviewCount;
  final String? exampleSentence;

  Vocabulary({
    this.id,
    required this.word,
    required this.translation,
    required this.language,
    this.proficiency = 1,
    required this.firstSeen,
    required this.lastReviewed,
    this.reviewCount = 0,
    this.exampleSentence,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'language': language,
      'proficiency': proficiency,
      'first_seen': firstSeen,
      'last_reviewed': lastReviewed,
      'review_count': reviewCount,
      'example_sentence': exampleSentence,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] as int?,
      word: map['word'] as String,
      translation: map['translation'] as String,
      language: map['language'] as String,
      proficiency: map['proficiency'] as int,
      firstSeen: map['first_seen'] as int,
      lastReviewed: map['last_reviewed'] as int,
      reviewCount: map['review_count'] as int,
      exampleSentence: map['example_sentence'] as String?,
    );
  }

  Vocabulary copyWith({
    int? id,
    String? word,
    String? translation,
    String? language,
    int? proficiency,
    int? firstSeen,
    int? lastReviewed,
    int? reviewCount,
    String? exampleSentence,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      language: language ?? this.language,
      proficiency: proficiency ?? this.proficiency,
      firstSeen: firstSeen ?? this.firstSeen,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      exampleSentence: exampleSentence ?? this.exampleSentence,
    );
  }

  @override
  String toString() {
    return 'Vocabulary(word: $word, translation: $translation, proficiency: $proficiency)';
  }
}
