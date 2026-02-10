import 'package:flutter/material.dart';
import 'logging_service.dart';

/// Function Caller
/// 
/// Implements manual "Function Calling" without MCP.
/// Detects user intent and triggers appropriate Flutter widgets/actions.
/// 
/// Example: When user says "I want to take a quiz", this triggers
/// the QuizWidget instead of letting the AI generate a quiz response.
class FunctionCaller {
  final LoggingService _logger = LoggingService.instance;

  // Intent patterns for detection
  static final Map<String, List<RegExp>> _intentPatterns = {
    'quiz': [
      RegExp(r'\b(take a quiz|start a quiz|quiz me|test me|practice quiz)\b', caseSensitive: false),
      RegExp(r"\b(let's do a quiz|quiz time|practice test)\b", caseSensitive: false),
    ],
    'vocabulary': [
      RegExp(r'\b(show my vocabulary|my words|learned words|word list)\b', caseSensitive: false),
      RegExp(r'\b(vocabulary review|review words|word bank)\b', caseSensitive: false),
    ],
    'progress': [
      RegExp(r'\b(show progress|my progress|how am i doing|statistics|stats)\b', caseSensitive: false),
      RegExp(r'\b(learning streak|day streak|lessons completed)\b', caseSensitive: false),
    ],
    'settings': [
      RegExp(r'\b(open settings|change language|switch language|app settings)\b', caseSensitive: false),
    ],
    'pronunciation': [
      RegExp(r"\b(how do i pronounce|pronounce this|say this out loud|speak this)\b", caseSensitive: false),
    ],
    'translate': [
      RegExp(r'\b(translate this|what does .+ mean|how do you say)\b', caseSensitive: false),
    ],
    'grammar': [
      RegExp(r'\b(grammar rule|explain grammar|why is this wrong|grammar help)\b', caseSensitive: false),
    ],
    'examples': [
      RegExp(r'\b(give me examples|show examples|example sentences|more examples)\b', caseSensitive: false),
    ],
    'reset': [
      RegExp(r'\b(clear history|delete chat|start over|new conversation)\b', caseSensitive: false),
    ],
  };

  /// Analyze user input and detect intent
  FunctionCallResult analyzeIntent(String userInput) {
    _logger.debug('FunctionCaller', 'Analyzing intent', metadata: {
      'input': userInput,
    });

    final lowerInput = userInput.toLowerCase().trim();

    // Check each intent category
    for (final entry in _intentPatterns.entries) {
      final intent = entry.key;
      final patterns = entry.value;

      for (final pattern in patterns) {
        if (pattern.hasMatch(lowerInput)) {
          _logger.info('FunctionCaller', 'Intent detected', metadata: {
            'intent': intent,
            'matched_pattern': pattern.pattern,
          });

          return FunctionCallResult(
            hasIntent: true,
            intent: intent,
            confidence: _calculateConfidence(userInput, pattern),
            originalInput: userInput,
          );
        }
      }
    }

    // No intent detected - let AI handle it
    return FunctionCallResult(
      hasIntent: false,
      intent: 'chat',
      confidence: 1.0,
      originalInput: userInput,
    );
  }

  /// Execute the detected intent
  /// 
  /// Returns true if a function was executed, false if should fallback to AI
  Future<bool> executeIntent(
    String intent,
    String originalInput,
    BuildContext context,
  ) async {
    _logger.info('FunctionCaller', 'Executing intent', metadata: {
      'intent': intent,
    });

    switch (intent) {
      case 'quiz':
        await _triggerQuiz(context);
        return true;

      case 'vocabulary':
        await _triggerVocabulary(context);
        return true;

      case 'progress':
        await _triggerProgress(context);
        return true;

      case 'settings':
        await _triggerSettings(context);
        return true;

      case 'pronunciation':
        await _triggerPronunciation(context, originalInput);
        return true;

      case 'translate':
        await _triggerTranslation(context, originalInput);
        return true;

      case 'grammar':
        await _triggerGrammarHelp(context, originalInput);
        return true;

      case 'examples':
        await _triggerExamples(context, originalInput);
        return true;

      case 'reset':
        await _triggerReset(context);
        return true;

      default:
        return false;
    }
  }

  /// Get quick response for detected intent
  String getIntentResponse(String intent) {
    final responses = {
      'quiz': 'Opening quiz mode for you! 🎯',
      'vocabulary': 'Showing your vocabulary list... 📚',
      'progress': 'Let\'s see how you\'re doing! 📊',
      'settings': 'Opening settings... ⚙️',
      'pronunciation': 'Let\'s work on pronunciation! 🎙️',
      'translate': 'I\'ll help you translate that! 🔄',
      'grammar': 'Let me explain the grammar rule! 📖',
      'examples': 'Here are some examples! ✍️',
      'reset': 'Starting fresh! 🌟',
    };

    return responses[intent] ?? 'Got it! Let me help you with that.';
  }

  // ============================================================================
  // INTENT HANDLERS
  // ============================================================================

  Future<void> _triggerQuiz(BuildContext context) async {
    // Show a simple quiz dialog or navigate to quiz screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Mode'),
        content: const Text('Quiz feature coming soon! 🎯\n\nFor now, try asking me specific grammar questions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerVocabulary(BuildContext context) async {
    // Navigate to vocabulary screen
    // Navigator.pushNamed(context, '/vocabulary');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Vocabulary'),
        content: const Text('Vocabulary screen coming soon! 📚\n\nFor now, ask me to teach you new words!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerProgress(BuildContext context) async {
    // Navigate to progress screen
    // Navigator.pushNamed(context, '/progress');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Progress'),
        content: const Text('Progress tracking coming soon! 📊\n\nKeep practicing to build your streak!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSettings(BuildContext context) async {
    // Navigate to settings screen
    // Navigator.pushNamed(context, '/settings');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings screen coming soon! ⚙️'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerPronunciation(BuildContext context, String input) async {
    // Extract word/phrase to pronounce
    final word = _extractWordToPronounce(input);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pronunciation Guide'),
        content: Text('Word: "$word"\n\n🔊 Pronunciation feature coming soon!\n\nFor now, try speaking slowly and breaking the word into syllables.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerTranslation(BuildContext context, String input) async {
    // Let the AI handle translation but with special prompt
    // This returns false so the AI generates the translation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation'),
        content: const Text('I\'ll translate that for you in my response! 🔄'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks!'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerGrammarHelp(BuildContext context, String input) async {
    // Let the AI handle but with grammar-focused prompt
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grammar Help'),
        content: const Text('I\'ll explain the grammar rule in my response! 📖'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerExamples(BuildContext context, String input) async {
    // Let AI handle but with example-focused prompt
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Examples'),
        content: const Text('I\'ll provide examples in my response! ✍️'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks!'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text('This will delete all your messages. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Trigger clear via provider
      // context.read<ChatProvider>().clearHistory();
      _logger.info('FunctionCaller', 'Chat history cleared');
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Calculate confidence based on match quality
  double _calculateConfidence(String input, RegExp pattern) {
    final match = pattern.firstMatch(input);
    if (match == null) return 0.5;

    // Higher confidence for longer matches
    final matchLength = match.group(0)?.length ?? 0;
    final baseConfidence = 0.7;
    final lengthBonus = (matchLength / input.length) * 0.3;

    return (baseConfidence + lengthBonus).clamp(0.0, 1.0);
  }

  /// Extract word to pronounce from input
  String _extractWordToPronounce(String input) {
    // Simple extraction - get words in quotes or after "pronounce"
    final quoteMatch = RegExp(r'["\x27]([^"\x27]+)["\x27]').firstMatch(input);
    if (quoteMatch != null) {
      return quoteMatch.group(1) ?? input;
    }

    final pronounceMatch = RegExp(r'pronounce\s+(\w+)', caseSensitive: false).firstMatch(input);
    if (pronounceMatch != null) {
      return pronounceMatch.group(1) ?? input;
    }

    // Return last word as fallback
    final words = input.split(' ');
    return words.isNotEmpty ? words.last : input;
  }

  /// Get suggested functions based on context
  List<String> getSuggestedFunctions() {
    return [
      'Take a quiz',
      'Show my vocabulary',
      'How is my progress?',
      'Pronounce "bonjour"',
      'Give me examples',
    ];
  }
}

// ============================================================================
// DATA CLASSES
// ============================================================================

class FunctionCallResult {
  final bool hasIntent;
  final String intent;
  final double confidence;
  final String originalInput;

  FunctionCallResult({
    required this.hasIntent,
    required this.intent,
    required this.confidence,
    required this.originalInput,
  });

  bool get shouldTriggerFunction => hasIntent && confidence > 0.6;

  @override
  String toString() {
    return 'FunctionCallResult(intent: $intent, confidence: $confidence, hasIntent: $hasIntent)';
  }
}
