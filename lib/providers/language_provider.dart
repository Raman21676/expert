import 'package:flutter/foundation.dart';
import '../services/storage/preferences_service.dart';

/// Language Provider
/// 
/// Manages language selection and localization state
class LanguageProvider with ChangeNotifier {
  final PreferencesService _prefs;

  LanguageProvider({PreferencesService? prefs})
      : _prefs = prefs ?? PreferencesService.instance;

  // Available languages
  static const Map<String, Map<String, String>> supportedLanguages = {
    'en': {'name': 'English', 'nativeName': 'English', 'flag': '🇺🇸'},
    'hi': {'name': 'Hindi', 'nativeName': 'हिन्दी', 'flag': '🇮🇳'},
    'ne': {'name': 'Nepali', 'nativeName': 'नेपाली', 'flag': '🇳🇵'},
    'zh': {'name': 'Chinese', 'nativeName': '中文', 'flag': '🇨🇳'},
    'fr': {'name': 'French', 'nativeName': 'Français', 'flag': '🇫🇷'},
    'es': {'name': 'Spanish', 'nativeName': 'Español', 'flag': '🇪🇸'},
    'ja': {'name': 'Japanese', 'nativeName': '日本語', 'flag': '🇯🇵'},
    'ar': {'name': 'Arabic', 'nativeName': 'العربية', 'flag': '🇸🇦'},
    'de': {'name': 'German', 'nativeName': 'Deutsch', 'flag': '🇩🇪'},
    'ko': {'name': 'Korean', 'nativeName': '한국어', 'flag': '🇰🇷'},
    'ru': {'name': 'Russian', 'nativeName': 'Русский', 'flag': '🇷🇺'},
    'pt': {'name': 'Portuguese', 'nativeName': 'Português', 'flag': '🇧🇷'},
    'it': {'name': 'Italian', 'nativeName': 'Italiano', 'flag': '🇮🇹'},
  };

  // Getters
  String? get nativeLanguage => _prefs.nativeLanguage;
  String? get targetLanguage => _prefs.targetLanguage;
  String get proficiencyLevel => _prefs.proficiencyLevel ?? 'beginner';

  String? get nativeLanguageName => _getLanguageName(nativeLanguage);
  String? get targetLanguageName => _getLanguageName(targetLanguage);

  bool get hasSelectedLanguages => nativeLanguage != null && targetLanguage != null;

  /// Get language display name
  String _getLanguageName(String? code) {
    if (code == null) return '';
    return supportedLanguages[code]?['nativeName'] ?? code.toUpperCase();
  }

  /// Set native language
  Future<void> setNativeLanguage(String languageCode) async {
    await _prefs.setNativeLanguage(languageCode);
    notifyListeners();
  }

  /// Set target language
  Future<void> setTargetLanguage(String languageCode) async {
    await _prefs.setTargetLanguage(languageCode);
    notifyListeners();
  }

  /// Set proficiency level
  Future<void> setProficiencyLevel(String level) async {
    await _prefs.setProficiencyLevel(level);
    notifyListeners();
  }

  /// Get list of languages that can be learned (all except native)
  List<MapEntry<String, Map<String, String>>> getAvailableTargetLanguages() {
    return supportedLanguages.entries
        .where((entry) => entry.key != nativeLanguage)
        .toList();
  }

  /// Get language info
  Map<String, String>? getLanguageInfo(String code) {
    return supportedLanguages[code];
  }

  /// Check if languages are valid for learning
  bool canStartLearning() {
    if (nativeLanguage == null || targetLanguage == null) return false;
    if (nativeLanguage == targetLanguage) return false;
    return true;
  }
}
