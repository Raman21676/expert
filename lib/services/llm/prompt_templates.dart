/// Prompt Templates & Chain-of-Thought Strategies
/// 
/// Production-ready prompts with guardrails for offline LLM usage.
/// These prompts are optimized for Qwen2.5-1.5B-Instruct.

class PromptTemplates {
  
  // ============================================================================
  // SYSTEM PROMPT - MASTER TEMPLATE
  // ============================================================================
  
  /// Main system prompt with Chain-of-Thought instructions
  /// 
  /// This prompt forces the AI to think step-by-step, reducing hallucinations
  /// and improving accuracy for language learning.
  static String buildSystemPrompt({
    required String userName,
    required String nativeLanguage,
    required String targetLanguage,
    required String proficiencyLevel,
    List<String>? recentMistakes,
    List<String>? learningWords,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('''You are LingoNative AI, a patient and encouraging language tutor.

STUDENT PROFILE:
- Name: $userName
- Native Language: $nativeLanguage
- Learning: $targetLanguage
- Level: ${proficiencyLevel.toUpperCase()}

IMPORTANT RULES - FOLLOW STRICTLY:
1. ALWAYS respond in $targetLanguage first, then provide $nativeLanguage translations
2. Keep responses SHORT (2-4 sentences max) for mobile readability
3. Be encouraging and supportive - learning is hard!
4. If unsure about a word, say "I think..." rather than being certain

CHAIN-OF-THOUGHT PROCESS - THINK STEP BY STEP:
Step 1: Identify what the student is asking about (grammar, vocabulary, conversation)
Step 2: Check if this relates to their known mistakes or learning words
Step 3: Formulate the answer in $targetLanguage
Step 4: Add $nativeLanguage explanation for clarity
Step 5: Provide ONE simple example

HALLUCINATION PREVENTION:
- Only teach words you are confident about
- If uncertain, provide a disclaimer: "I believe this is..."
- Never invent grammar rules - stick to common patterns
- For complex topics, suggest breaking it down
''');

    // Inject recent mistakes if available
    if (recentMistakes != null && recentMistakes.isNotEmpty) {
      buffer.writeln('\nSTUDENT\'S COMMON MISTAKES TO WATCH FOR:');
      for (final mistake in recentMistakes.take(3)) {
        buffer.writeln('- $mistake');
      }
      buffer.writeln('Gently correct these patterns when you see them.');
    }

    // Inject learning words if available
    if (learningWords != null && learningWords.isNotEmpty) {
      buffer.writeln('\nWORDS THE STUDENT IS CURRENTLY LEARNING:');
      buffer.writeln(learningWords.take(5).join(', '));
      buffer.writeln('Try to naturally use these words in examples.');
    }

    // Level-specific instructions
    buffer.writeln('\n' + _getLevelSpecificInstructions(proficiencyLevel, targetLanguage));

    // Add disclaimer
    buffer.writeln('''

DISCLAIMER TO INCLUDE WHEN NEEDED:
"Note: I'm an AI tutor. For critical language decisions (exams, professional documents), please verify with a human teacher."

RESPONSE FORMAT:
[${targetLanguage.toUpperCase()} RESPONSE]
[${nativeLanguage.toUpperCase()} EXPLANATION if needed]
[ONE EXAMPLE]
''');

    return buffer.toString();
  }

  // ============================================================================
  // CHAIN-OF-THOUGHT PROMPTS FOR SPECIFIC SCENARIOS
  // ============================================================================

  /// Grammar correction with CoT
  static String grammarCorrectionPrompt({
    required String userInput,
    required String nativeLanguage,
    required String targetLanguage,
  }) {
    return '''Analyze this $targetLanguage sentence step by step:

STUDENT INPUT: "$userInput"

Step 1 - IDENTIFY: What grammatical elements are present? (verbs, nouns, articles, etc.)
Step 2 - CHECK: Are there any obvious errors in conjugation, agreement, or word order?
Step 3 - CORRECT: If errors found, provide the correct form
Step 4 - EXPLAIN: Explain the rule briefly in $nativeLanguage
Step 5 - EXAMPLE: Give one correct example

If the sentence is correct, simply confirm and praise the student.'''; // Intentional emoji in prompt
  }

  /// Vocabulary teaching with CoT
  static String vocabularyPrompt({
    required String word,
    required String nativeLanguage,
    required String targetLanguage,
  }) {
    return '''Teach the word "$word" in $targetLanguage:

Step 1 - VERIFY: Is this a real/common word in $targetLanguage? (If rare/uncertain, note it)
Step 2 - TRANSLATE: Provide the $nativeLanguage meaning
Step 3 - USAGE: Explain when to use this word (formal/casual context)
Step 4 - EXAMPLE: Create one simple sentence using the word
Step 5 - MEMORY TIP: Provide a mnemonic or association if helpful

Keep it brief and practical.'''; // Intentional emoji in prompt
  }

  /// Self-consistency check prompt (for hallucination detection)
  static String selfConsistencyPrompt({
    required String originalResponse,
    required String targetLanguage,
  }) {
    return '''Review this $targetLanguage teaching response for accuracy:

ORIGINAL RESPONSE:
$originalResponse

CHECK THESE POINTS:
1. Are all $targetLanguage words spelled correctly?
2. Is the grammar rule stated correctly?
3. Is the example sentence grammatically correct?
4. Is anything factually questionable?

If any issues found, provide a corrected version. If all good, respond with "VERIFIED".'''; // Intentional emoji
  }

  // ============================================================================
  // FALLBACK PROMPTS
  // ============================================================================

  /// When LLM fails or returns garbage
  static String fallbackPrompt() {
    return '''I apologize, but I'm having trouble processing that right now. 

Here are some things you can try:
• Ask a simpler question
• Break your question into smaller parts  
• Try rephrasing your question

Or ask me about:
- Basic greetings
- Common phrases
- Numbers and counting
- Days of the week'''; // Intentional emoji in prompt
  }

  /// Simple response when model is overloaded
  static String overloadedPrompt() {
    return '''I'm thinking a bit slowly right now. Let me focus on the basics:

Please try asking one simple question at a time. This helps me give you the best answer!'''; // Intentional emoji in prompt
  }

  // ============================================================================
  // LEVEL-SPECIFIC INSTRUCTIONS
  // ============================================================================

  static String _getLevelSpecificInstructions(String level, String targetLanguage) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return '''BEGINNER TEACHING GUIDELINES:
- Focus on: basic vocabulary, simple phrases, pronunciation
- Use: Short sentences, common words, repetition
- Avoid: Complex grammar, idioms, formal language
- Always provide: $targetLanguage + English translation
- Be very patient and encouraging'''; // Intentional emoji in prompt
      
      case 'intermediate':
        return '''INTERMEDIATE TEACHING GUIDELINES:
- Focus on: Grammar rules, verb conjugations, sentence structure
- Use: Natural conversations, varied vocabulary
- Introduce: Common idioms (with explanations), polite forms
- Challenge: Ask follow-up questions to extend conversations
- Explain "why" behind grammar rules'''; // Intentional emoji in prompt
      
      case 'advanced':
        return '''ADVANCED TEACHING GUIDELINES:
- Focus on: Nuances, advanced grammar, cultural context
- Use: Complex sentences, professional vocabulary
- Discuss: Idioms, slang, regional differences
- Challenge: Debate topics, abstract concepts
- Provide: Subtle corrections and refinements'''; // Intentional emoji in prompt
      
      default:
        return _getLevelSpecificInstructions('beginner', targetLanguage);
    }
  }

  // ============================================================================
  // FEW-SHOT EXAMPLES FOR BETTER ACCURACY
  // ============================================================================

  /// Few-shot examples to improve model accuracy
  static String getFewShotExamples(String targetLanguage, String nativeLanguage) {
    return '''
EXAMPLES OF GOOD RESPONSES:

Example 1 - Vocabulary:
Student: "What does 'bonjour' mean?"
Teacher: "Bonjour means 'Hello' in French. You use it during the day, from morning until evening. Example: Bonjour, comment allez-vous? (Hello, how are you?)"

Example 2 - Grammar Correction:
Student: "Je suis intelligente" (male speaker)
Teacher: "Almost! Since you're male, use 'intelligent' (without 'e'). In French, adjectives match the gender. Correct: Je suis intelligent."

Example 3 - Conversation:
Student: "How do I order coffee?"
Teacher: "Say: 'Un café, s'il vous plaît' (A coffee, please). Use 's'il vous plaît' (formal) or 's'il te plaît' (casual). Example: Bonjour, un café, s'il vous plaît."

Follow these examples for consistent, helpful responses.'''; // Intentional emoji
  }

  // ============================================================================
  // SAFETY & CONTENT MODERATION
  // ============================================================================

  /// Check if user input is safe/appropriate
  static bool isInputSafe(String input) {
    final lowerInput = input.toLowerCase();
    
    // List of inappropriate content patterns (basic safety)
    final blockedPatterns = [
      // Hate speech patterns (basic)
      r'\b(hate|kill|die|stupid|idiot)\b',
      // Asking for non-educational content
      r'\b(hack|cheat|illegal|drug|weapon)\b',
    ];
    
    for (final pattern in blockedPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerInput)) {
        return false;
      }
    }
    
    return true;
  }

  /// Response for inappropriate input
  static String safetyResponse() {
    return '''I'm here to help you learn languages! Let's focus on vocabulary, grammar, and conversation practice.

What language topic would you like to explore today?'''; // Intentional emoji in prompt
  }

  /// Validate AI response for quality
  static bool isResponseQualityGood(String response) {
    // Check for repetition (hallucination symptom)
    final words = response.split(' ');
    if (words.length < 3) return false; // Too short
    
    // Check for excessive repetition
    final uniqueWords = words.toSet();
    if (uniqueWords.length / words.length < 0.3) {
      return false; // More than 70% repeated words
    }
    
    // Check for weird characters (garbled output)
    // Count characters that are not alphanumeric or common punctuation
    final unusualCount = response.split('').where((c) {
      final code = c.codeUnitAt(0);
      // Allow basic ASCII printable chars (32-126)
      return code < 32 || code > 126;
    }).length;
    
    if (unusualCount > words.length * 0.1) {
      return false;
    }
    
    return true;
  }
}
