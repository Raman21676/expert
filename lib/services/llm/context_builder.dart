import '../../core/database/database_helper.dart';
import '../../core/database/models/user_profile.dart';
import '../../core/database/models/chat_message.dart';
import '../../core/database/models/mistake.dart';
import '../../core/database/models/vocabulary.dart';

/// Context Builder
/// 
/// Builds intelligent prompts by injecting user context, conversation history,
/// vocabulary, and mistakes into each prompt. This is how the AI "remembers"
/// without storing state in the model itself.
class ContextBuilder {
  final DatabaseHelper _db;

  ContextBuilder({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  /// Build a complete prompt with all context
  Future<String> buildPrompt({
    required UserProfile profile,
    required String userMessage,
    int maxHistoryMessages = 10,
    int maxMistakes = 3,
    int maxVocabulary = 5,
  }) async {
    // Fetch context data
    final recentMessages = await _db.getRecentMessages(limit: maxHistoryMessages);
    final recentMistakes = await _db.getRecentMistakes(limit: maxMistakes);
    final recentVocab = await _db.getRecentlyLearnedWords(
      limit: maxVocabulary,
      language: profile.targetLanguage,
    );

    // Build context sections
    final systemPrompt = _buildSystemPrompt(profile);
    final historyPrompt = _buildHistoryPrompt(recentMessages);
    final mistakesPrompt = _buildMistakesPrompt(recentMistakes);
    final vocabPrompt = _buildVocabularyPrompt(recentVocab);

    // Combine all sections
    return '''$systemPrompt

$historyPrompt
$vocabPrompt
$mistakesPrompt

CURRENT MESSAGE:
Student: $userMessage

Tutor:'''; // The model will complete from here
  }

  /// Build the system prompt with user profile
  String _buildSystemPrompt(UserProfile profile) {
    return '''You are LingoNative AI, a friendly and patient language tutor.

STUDENT PROFILE:
- Name: ${profile.name}
- Native Language: ${_getLanguageName(profile.nativeLanguage)}
- Learning: ${_getLanguageName(profile.targetLanguage)}
- Level: ${profile.proficiencyLevel.toUpperCase()}

YOUR ROLE:
1. Teach ${_getLanguageName(profile.targetLanguage)} through ${_getLanguageName(profile.nativeLanguage)}
2. Be encouraging, patient, and supportive
3. Correct mistakes gently with explanations
4. Use simple examples and analogies
5. Keep responses concise (2-4 sentences)
6. Explain grammar concepts using ${_getLanguageName(profile.nativeLanguage)} when helpful

TEACHING STYLE:
- For BEGINNERS: Use basic vocabulary, focus on pronunciation and simple phrases
- For INTERMEDIATE: Introduce grammar rules, common expressions
- For ADVANCED: Focus on nuances, idioms, complex grammar

IMPORTANT RULES:
- Always respond primarily in ${_getLanguageName(profile.targetLanguage)}
- Provide ${_getLanguageName(profile.nativeLanguage)} translations for new words
- If the student makes a mistake, correct it kindly
- Use emojis occasionally to keep it friendly 😊'''; // Intentional emoji in prompt
  }

  /// Build conversation history section
  String _buildHistoryPrompt(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return 'CONVERSATION HISTORY:\n(No previous messages - this is a new conversation)';
    }

    final buffer = StringBuffer('CONVERSATION HISTORY:\n');
    
    for (final msg in messages) {
      final role = msg.role == 'user' ? 'Student' : 'Tutor';
      // Truncate very long messages for context window efficiency
      var content = msg.content;
      if (content.length > 200) {
        content = '${content.substring(0, 200)}...';
      }
      buffer.writeln('$role: $content');
    }

    return buffer.toString();
  }

  /// Build vocabulary context section
  String _buildVocabularyPrompt(List<Vocabulary> vocabulary) {
    if (vocabulary.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('\nWORDS THE STUDENT IS LEARNING:\n');
    
    for (final vocab in vocabulary) {
      buffer.writeln('- ${vocab.word} = ${vocab.translation} '
          '(level: ${vocab.proficiency}/5)');
    }
    
    buffer.writeln('\nTry to naturally incorporate these words in your teaching.');

    return buffer.toString();
  }

  /// Build mistakes context section
  String _buildMistakesPrompt(List<Mistake> mistakes) {
    if (mistakes.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('\nCOMMON MISTAKES TO WATCH FOR:\n');
    
    for (final mistake in mistakes) {
      buffer.writeln('- ❌ "${mistake.mistakeText}" → ✅ "${mistake.correction}"');
      if (mistake.mistakeType != null) {
        buffer.writeln('  (${mistake.mistakeType})');
      }
    }

    buffer.writeln('\nWatch for these patterns and provide gentle corrections.');

    return buffer.toString();
  }

  /// Get human-readable language name from code
  String _getLanguageName(String code) {
    final languages = {
      'en': 'English',
      'hi': 'Hindi',
      'ne': 'Nepali',
      'zh': 'Chinese',
      'fr': 'French',
      'es': 'Spanish',
      'ja': 'Japanese',
      'ar': 'Arabic',
      'de': 'German',
      'ko': 'Korean',
      'ru': 'Russian',
      'pt': 'Portuguese',
      'it': 'Italian',
    };
    return languages[code.toLowerCase()] ?? code.toUpperCase();
  }

  /// Build a simple prompt without full context (for quick responses)
  String buildSimplePrompt({
    required UserProfile profile,
    required String userMessage,
  }) {
    return '''You are teaching ${profile.targetLanguage} to ${profile.name}, a ${profile.nativeLanguage} speaker at ${profile.proficiencyLevel} level.

Student: $userMessage

Respond in ${profile.targetLanguage} with ${profile.nativeLanguage} translations for new words:''';
  }
}
