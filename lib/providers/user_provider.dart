import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../core/database/models/user_profile.dart';
import '../services/storage/preferences_service.dart';

/// User Provider
/// 
/// Manages user profile state across the app
class UserProvider with ChangeNotifier {
  final DatabaseHelper _db;
  final PreferencesService _prefs;

  UserProfile? _profile;
  bool _isLoading = false;

  UserProvider({
    DatabaseHelper? db,
    PreferencesService? prefs,
  })  : _db = db ?? DatabaseHelper.instance,
        _prefs = prefs ?? PreferencesService.instance;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  String? get name => _profile?.name;
  String? get nativeLanguage => _profile?.nativeLanguage;
  String? get targetLanguage => _profile?.targetLanguage;
  String get proficiencyLevel => _profile?.proficiencyLevel ?? 'beginner';
  int get learningStreak => _profile?.learningStreak ?? 0;
  int get totalLessons => _profile?.totalLessons ?? 0;

  /// Load user profile from database
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _db.getUserProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new user profile
  Future<void> createProfile({
    required String name,
    required String nativeLanguage,
    required String targetLanguage,
    String proficiencyLevel = 'beginner',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final profile = UserProfile(
        name: name,
        nativeLanguage: nativeLanguage,
        targetLanguage: targetLanguage,
        proficiencyLevel: proficiencyLevel,
        createdAt: now,
        lastActive: now,
      );

      final id = await _db.createUserProfile(profile);
      _profile = profile.copyWith(id: id);

      // Also save to preferences for quick access
      await _prefs.saveUserProfile({
        'name': name,
        'nativeLanguage': nativeLanguage,
        'targetLanguage': targetLanguage,
        'proficiencyLevel': proficiencyLevel,
      });

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserProfile updatedProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateUserProfile(updatedProfile);
      _profile = updatedProfile;

      await _prefs.saveUserProfile({
        'name': updatedProfile.name,
        'nativeLanguage': updatedProfile.nativeLanguage,
        'targetLanguage': updatedProfile.targetLanguage,
        'proficiencyLevel': updatedProfile.proficiencyLevel,
      });

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update last active timestamp
  Future<void> updateLastActive() async {
    if (_profile == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = _profile!.copyWith(lastActive: now);
    
    await _db.updateUserProfile(updated);
    _profile = updated;
    
    // Don't notify listeners to avoid unnecessary rebuilds
  }

  /// Increment learning streak
  Future<void> incrementStreak() async {
    if (_profile == null) return;

    final updated = _profile!.copyWith(
      learningStreak: _profile!.learningStreak + 1,
    );

    await updateProfile(updated);
  }

  /// Increment total lessons
  Future<void> incrementLessons() async {
    if (_profile == null) return;

    final updated = _profile!.copyWith(
      totalLessons: _profile!.totalLessons + 1,
    );

    await updateProfile(updated);
  }

  /// Delete user profile and all data
  Future<void> deleteProfile() async {
    if (_profile?.id != null) {
      await _db.deleteUserProfile(_profile!.id!);
      await _db.deleteAllData();
      await _prefs.clearAll();
      _profile = null;
      notifyListeners();
    }
  }
}
