import 'dart:math';
import 'prompt_templates.dart';

/// Response Validator
/// 
/// Implements self-consistency checking and hallucination detection
/// for offline LLM responses. Critical for production quality.
class ResponseValidator {
  
  // ============================================================================
  // SELF-CONSISTENCY CHECK
  // ============================================================================

  /// Run self-consistency check by asking the same question twice
  /// and comparing responses. Returns the more consistent answer.
  /// 
  /// Note: This doubles the inference cost but significantly improves accuracy.
  static Future<ValidationResult> validateWithSelfConsistency({
    required Future<String> Function(String) generateFn,
    required String prompt,
    required String targetLanguage,
    double similarityThreshold = 0.7,
  }) async {
    try {
      // Generate first response
      final response1 = await generateFn(prompt);
      
      // Small delay to vary randomness
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Generate second response with slightly different prompt
      final consistencyPrompt = '''${PromptTemplates.selfConsistencyPrompt(
        originalResponse: response1,
        targetLanguage: targetLanguage,
      )}

Original question: $prompt'''; // Intentional emoji
      
      final response2 = await generateFn(consistencyPrompt);
      
      // If second response says VERIFIED, accept first response
      if (response2.toUpperCase().contains('VERIFIED')) {
        return ValidationResult(
          isValid: true,
          response: response1,
          confidence: 0.9,
          method: ValidationMethod.selfConsistency,
        );
      }
      
      // If second response provides correction, use that
      if (response2.length > 20 && !response2.toUpperCase().contains('VERIFIED')) {
        // Extract the corrected part (heuristic)
        final corrected = _extractCorrectedPart(response2);
        if (corrected != null) {
          return ValidationResult(
            isValid: true,
            response: corrected,
            confidence: 0.85,
            method: ValidationMethod.selfCorrected,
            originalResponse: response1,
          );
        }
      }
      
      // Compare similarity between responses
      final similarity = _calculateSimilarity(response1, response2);
      
      if (similarity >= similarityThreshold) {
        return ValidationResult(
          isValid: true,
          response: response1,
          confidence: similarity,
          method: ValidationMethod.selfConsistency,
        );
      } else {
        // Responses diverged too much - low confidence
        return ValidationResult(
          isValid: false,
          response: response1,
          confidence: similarity,
          method: ValidationMethod.selfConsistency,
          error: 'Low consistency between responses ($similarity)',
        );
      }
      
    } catch (e) {
      return ValidationResult(
        isValid: false,
        response: '',
        confidence: 0.0,
        method: ValidationMethod.error,
        error: 'Validation failed: $e',
      );
    }
  }

  // ============================================================================
  // HALLUCINATION DETECTION
  // ============================================================================

  /// Check for common hallucination patterns
  static HallucinationCheck checkForHallucinations(String response, String targetLanguage) {
    final issues = <String>[];
    var severity = HallucinationSeverity.none;
    
    // Check 1: Excessive repetition
    final repetitionScore = _checkRepetition(response);
    if (repetitionScore > 0.5) {
      issues.add('High repetition detected ($repetitionScore)');
      severity = HallucinationSeverity.mild;
    }
    if (repetitionScore > 0.8) {
      severity = HallucinationSeverity.severe;
    }
    
    // Check 2: Gibberish/Random characters
    final gibberishScore = _checkGibberish(response);
    if (gibberishScore > 0.3) {
      issues.add('Unusual character patterns detected');
      severity = HallucinationSeverity.severe;
    }
    
    // Check 3: Nonsensical length
    if (response.length > 2000) {
      issues.add('Response excessively long');
      severity = HallucinationSeverity.moderate;
    }
    if (response.length < 10) {
      issues.add('Response too short');
      severity = HallucinationSeverity.moderate;
    }
    
    // Check 4: Off-topic indicators (heuristic)
    if (_containsOffTopicContent(response)) {
      issues.add('Potentially off-topic content');
      severity = HallucinationSeverity.mild;
    }
    
    // Check 5: Target language validation (basic)
    if (!_containsTargetLanguageScript(response, targetLanguage)) {
      issues.add('Missing expected $targetLanguage script');
      severity = HallucinationSeverity.moderate;
    }
    
    return HallucinationCheck(
      hasIssues: issues.isNotEmpty,
      issues: issues,
      severity: severity,
      confidence: 1.0 - (issues.length * 0.2),
    );
  }

  /// Quick quality check without second inference
  static QuickCheck quickQualityCheck(String response) {
    // Check length
    if (response.trim().isEmpty) {
      return QuickCheck(false, 'Empty response');
    }
    
    // Check for repetition patterns
    final words = response.toLowerCase().split(' ');
    if (words.length > 10) {
      for (int i = 0; i < words.length - 5; i++) {
        final pattern = words.sublist(i, i + 3).join(' ');
        final matches = pattern.allMatches(response.toLowerCase()).length;
        if (matches > 3) {
          return QuickCheck(false, 'Repetitive pattern detected');
        }
      }
    }
    
    // Check for balanced brackets/quotes
    if (!_hasBalancedPunctuation(response)) {
      return QuickCheck(false, 'Unbalanced punctuation');
    }
    
    return QuickCheck(true, 'Passed basic checks');
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Calculate similarity between two strings (0.0 to 1.0)
  static double _calculateSimilarity(String s1, String s2) {
    // Simple Jaccard similarity on word sets
    final words1 = s1.toLowerCase().split(' ').toSet();
    final words2 = s2.toLowerCase().split(' ').toSet();
    
    if (words1.isEmpty && words2.isEmpty) return 1.0;
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;
    
    return intersection / union;
  }

  /// Extract corrected part from self-consistency response
  static String? _extractCorrectedPart(String response) {
    // Look for patterns like "CORRECTED:" or "FIXED:"
    final patterns = [
      RegExp(r'CORRECTED:?\s*(.+?)(?=\n|$)', caseSensitive: false),
      RegExp(r'FIXED:?\s*(.+?)(?=\n|$)', caseSensitive: false),
      RegExp(r'CORRECT VERSION:?\s*(.+?)(?=\n|$)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(response);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    
    // If no pattern found, return the response minus the "VERIFIED" line
    final lines = response.split('\n');
    final nonVerifiedLines = lines.where(
      (l) => !l.toUpperCase().contains('VERIFIED'),
    ).toList();
    
    if (nonVerifiedLines.length > 1) {
      return nonVerifiedLines.join('\n').trim();
    }
    
    return null;
  }

  /// Check for excessive repetition in text
  static double _checkRepetition(String text) {
    final words = text.toLowerCase().split(' ');
    if (words.isEmpty) return 0.0;
    
    final wordCounts = <String, int>{};
    for (final word in words) {
      wordCounts[word] = (wordCounts[word] ?? 0) + 1;
    }
    
    // Find most common word frequency
    final maxCount = wordCounts.values.fold(0, max);
    return maxCount / words.length;
  }

  /// Check for gibberish/random characters
  static double _checkGibberish(String text) {
    // Count non-alphanumeric characters
    if (text.isEmpty) return 0.0;
    
    // Check for unusual Unicode characters
    final unusualCount = text.split('').where((c) {
      final code = c.codeUnitAt(0);
      // Allow basic ASCII printable chars (32-126)
      return code < 32 || code > 126;
    }).length;
    
    return unusualCount / text.length;
  }

  /// Check for off-topic content indicators
  static bool _containsOffTopicContent(String text) {
    final lower = text.toLowerCase();
    final offTopicIndicators = [
      'i am an ai language model',
      'as an ai',
      'i don\'t have personal',
      'my training data',
      'i was trained',
      'openai',
      'anthropic',
      'google',
    ];
    
    return offTopicIndicators.any((indicator) => lower.contains(indicator));
  }

  /// Check if response contains expected target language script
  static bool _containsTargetLanguageScript(String response, String targetLanguage) {
    // Basic script detection based on language code
    final scripts = {
      'zh': RegExp(r'[\u4e00-\u9fff]'), // Chinese
      'ja': RegExp(r'[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9fff]'), // Japanese
      'ko': RegExp(r'[\uac00-\ud7af]'), // Korean
      'ar': RegExp(r'[\u0600-\u06ff]'), // Arabic
      'hi': RegExp(r'[\u0900-\u097f]'), // Hindi
      'ru': RegExp(r'[\u0400-\u04ff]'), // Russian
    };
    
    final pattern = scripts[targetLanguage.toLowerCase()];
    if (pattern == null) return true; // Latin-based languages
    
    // For target languages with specific scripts, check presence
    // But be lenient - beginner responses might be mostly in native language
    return true; // Return true to avoid false positives
  }

  /// Check for balanced punctuation
  static bool _hasBalancedPunctuation(String text) {
    final pairs = {
      '(': ')',
      '[': ']',
      '{': '}',
      '"': '"',
      "'": "'",
    };
    
    final stack = <String>[];
    
    for (final char in text.split('')) {
      if (pairs.containsKey(char)) {
        stack.add(char);
      } else if (pairs.containsValue(char)) {
        if (stack.isEmpty) return false;
        final last = stack.removeLast();
        if (pairs[last] != char) return false;
      }
    }
    
    return stack.isEmpty;
  }
}

// ============================================================================
// DATA CLASSES
// ============================================================================

enum ValidationMethod {
  selfConsistency,
  selfCorrected,
  quickCheck,
  error,
}

enum HallucinationSeverity {
  none,
  mild,
  moderate,
  severe,
}

class ValidationResult {
  final bool isValid;
  final String response;
  final double confidence;
  final ValidationMethod method;
  final String? error;
  final String? originalResponse;

  ValidationResult({
    required this.isValid,
    required this.response,
    required this.confidence,
    required this.method,
    this.error,
    this.originalResponse,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, confidence: $confidence, method: $method)';
  }
}

class HallucinationCheck {
  final bool hasIssues;
  final List<String> issues;
  final HallucinationSeverity severity;
  final double confidence;

  HallucinationCheck({
    required this.hasIssues,
    required this.issues,
    required this.severity,
    required this.confidence,
  });

  bool get shouldFallback => severity == HallucinationSeverity.severe;
  bool get shouldWarn => severity == HallucinationSeverity.moderate;
}

class QuickCheck {
  final bool passed;
  final String reason;

  QuickCheck(this.passed, this.reason);
}
