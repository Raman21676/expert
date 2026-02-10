import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Preferences Service
/// 
/// Manages simple key-value storage using SharedPreferences.
/// Used for user settings, app state, and lightweight data.
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static PreferencesService get instance => _instance;

  SharedPreferences? _prefs;

  // Keys
  static const String _keyUserName = 'user_name';
  static const String _keyNativeLanguage = 'native_language';
  static const String _keyTargetLanguage = 'target_language';
  static const String _keyProficiencyLevel = 'proficiency_level';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyLastActive = 'last_active';
  static const String _keyLearningStreak = 'learning_streak';
  static const String _keyTotalLessons = 'total_lessons';
  static const String _keyModelDownloaded = 'model_downloaded';

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if initialized
  bool get isInitialized => _prefs != null;

  // ==================== USER PREFERENCES ====================

  String? get userName => _prefs?.getString(_keyUserName);
  Future<bool> setUserName(String value) async {
    return await _prefs?.setString(_keyUserName, value) ?? false;
  }

  String? get nativeLanguage => _prefs?.getString(_keyNativeLanguage);
  Future<bool> setNativeLanguage(String value) async {
    return await _prefs?.setString(_keyNativeLanguage, value) ?? false;
  }

  String? get targetLanguage => _prefs?.getString(_keyTargetLanguage);
  Future<bool> setTargetLanguage(String value) async {
    return await _prefs?.setString(_keyTargetLanguage, value) ?? false;
  }

  String? get proficiencyLevel => _prefs?.getString(_keyProficiencyLevel);
  Future<bool> setProficiencyLevel(String value) async {
    return await _prefs?.setString(_keyProficiencyLevel, value) ?? false;
  }

  // ==================== APP STATE ====================

  bool get isFirstLaunch => _prefs?.getBool(_keyIsFirstLaunch) ?? true;
  Future<bool> setFirstLaunch(bool value) async {
    return await _prefs?.setBool(_keyIsFirstLaunch, value) ?? false;
  }

  bool get isDarkMode => _prefs?.getBool(_keyIsDarkMode) ?? false;
  Future<bool> setDarkMode(bool value) async {
    return await _prefs?.setBool(_keyIsDarkMode, value) ?? false;
  }

  int? get lastActive => _prefs?.getInt(_keyLastActive);
  Future<bool> setLastActive(int value) async {
    return await _prefs?.setInt(_keyLastActive, value) ?? false;
  }

  int get learningStreak => _prefs?.getInt(_keyLearningStreak) ?? 0;
  Future<bool> setLearningStreak(int value) async {
    return await _prefs?.setInt(_keyLearningStreak, value) ?? false;
  }

  int get totalLessons => _prefs?.getInt(_keyTotalLessons) ?? 0;
  Future<bool> setTotalLessons(int value) async {
    return await _prefs?.setInt(_keyTotalLessons, value) ?? false;
  }

  bool get isModelDownloaded => _prefs?.getBool(_keyModelDownloaded) ?? false;
  Future<bool> setModelDownloaded(bool value) async {
    return await _prefs?.setBool(_keyModelDownloaded, value) ?? false;
  }

  // ==================== UTILITY METHODS ====================

  /// Check if user has completed onboarding
  bool get hasCompletedOnboarding {
    return userName != null && 
           nativeLanguage != null && 
           targetLanguage != null;
  }

  /// Get all preferences as a map (for debugging)
  Map<String, dynamic> getAll() {
    return {
      'userName': userName,
      'nativeLanguage': nativeLanguage,
      'targetLanguage': targetLanguage,
      'proficiencyLevel': proficiencyLevel,
      'isFirstLaunch': isFirstLaunch,
      'isDarkMode': isDarkMode,
      'lastActive': lastActive,
      'learningStreak': learningStreak,
      'totalLessons': totalLessons,
      'isModelDownloaded': isModelDownloaded,
    };
  }

  /// Clear all preferences (logout/reset)
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  /// Save user profile from map
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await setUserName(profile['name'] ?? '');
    await setNativeLanguage(profile['nativeLanguage'] ?? '');
    await setTargetLanguage(profile['targetLanguage'] ?? '');
    await setProficiencyLevel(profile['proficiencyLevel'] ?? 'beginner');
  }

  /// Get user profile as map
  Map<String, String?> getUserProfile() {
    return {
      'name': userName,
      'nativeLanguage': nativeLanguage,
      'targetLanguage': targetLanguage,
      'proficiencyLevel': proficiencyLevel,
    };
  }
}
