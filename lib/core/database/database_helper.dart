import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/chat_message.dart';
import 'models/user_profile.dart';
import 'models/vocabulary.dart';
import 'models/mistake.dart';

/// Central Database Helper
/// Manages SQLite database for all local persistence
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'lingoNative.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableUserProfile = 'user_profile';
  static const String tableChatMessages = 'chat_messages';
  static const String tableVocabulary = 'learned_vocabulary';
  static const String tableMistakes = 'mistake_log';

  // Compression threshold - messages older than this count get compressed
  static const int _compressionThreshold = 100;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';

    // User Profile Table
    await db.execute('''
      CREATE TABLE $tableUserProfile (
        id $idType,
        name $textType,
        native_language $textType,
        target_language $textType,
        proficiency_level TEXT CHECK(proficiency_level IN ('beginner', 'intermediate', 'advanced')) DEFAULT 'beginner',
        learning_streak $intType DEFAULT 0,
        total_lessons $intType DEFAULT 0,
        created_at $intType,
        last_active $intType
      )
    ''');

    // Chat Messages Table
    await db.execute('''
      CREATE TABLE $tableChatMessages (
        id $idType,
        role TEXT CHECK(role IN ('user', 'assistant')) NOT NULL,
        content $textType,
        timestamp $intType,
        tokens_used INTEGER,
        session_id TEXT,
        compressed $boolType DEFAULT 0
      )
    ''');

    // Index for faster timestamp queries
    await db.execute('''
      CREATE INDEX idx_timestamp ON $tableChatMessages(timestamp DESC)
    ''');

    // Index for session queries
    await db.execute('''
      CREATE INDEX idx_session ON $tableChatMessages(session_id)
    ''');

    // Vocabulary Table
    await db.execute('''
      CREATE TABLE $tableVocabulary (
        id $idType,
        word $textType,
        translation $textType,
        language $textType,
        proficiency INTEGER DEFAULT 1 CHECK(proficiency BETWEEN 1 AND 5),
        first_seen $intType,
        last_reviewed $intType,
        review_count INTEGER DEFAULT 0,
        example_sentence TEXT
      )
    ''');

    // Index for word lookups
    await db.execute('''
      CREATE INDEX idx_word ON $tableVocabulary(word)
    ''');

    // Mistake Log Table
    await db.execute('''
      CREATE TABLE $tableMistakes (
        id $idType,
        mistake_text $textType,
        correction $textType,
        mistake_type TEXT CHECK(mistake_type IN ('grammar', 'vocabulary', 'pronunciation', 'spelling')),
        occurrence_count INTEGER DEFAULT 1,
        first_made $intType,
        last_made $intType,
        mastered $boolType DEFAULT 0
      )
    ''');

    // Index for unmastered mistakes
    await db.execute('''
      CREATE INDEX idx_mastered ON $tableMistakes(mastered, last_made DESC)
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  // ==================== USER PROFILE OPERATIONS ====================

  Future<int> createUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert(tableUserProfile, profile.toMap());
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query(tableUserProfile, limit: 1);

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.update(
      tableUserProfile,
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteUserProfile(int id) async {
    final db = await database;
    return await db.delete(
      tableUserProfile,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CHAT MESSAGE OPERATIONS ====================

  Future<int> insertMessage(ChatMessage message) async {
    final db = await database;
    return await db.insert(tableChatMessages, message.toMap());
  }

  Future<List<ChatMessage>> getRecentMessages({int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      tableChatMessages,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.reversed.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<List<ChatMessage>> getMessagesBySession(String sessionId) async {
    final db = await database;
    final maps = await db.query(
      tableChatMessages,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<int> getMessageCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableChatMessages');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> compressOldMessages() async {
    final db = await database;
    final count = await getMessageCount();

    if (count > _compressionThreshold) {
      // Get oldest messages that aren't compressed yet
      final maps = await db.query(
        tableChatMessages,
        where: 'compressed = 0',
        orderBy: 'timestamp ASC',
        limit: count - _compressionThreshold,
      );

      // Mark them as compressed (in real implementation, you might actually compress the content)
      for (final map in maps) {
        await db.update(
          tableChatMessages,
          {'compressed': 1},
          where: 'id = ?',
          whereArgs: [map['id']],
        );
      }
    }
  }

  Future<int> deleteOldMessages(int daysOld) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: daysOld)).millisecondsSinceEpoch;
    return await db.delete(
      tableChatMessages,
      where: 'timestamp < ?',
      whereArgs: [cutoff],
    );
  }

  Future<void> clearAllMessages() async {
    final db = await database;
    await db.delete(tableChatMessages);
  }

  // ==================== VOCABULARY OPERATIONS ====================

  Future<int> addVocabulary(Vocabulary vocab) async {
    final db = await database;
    return await db.insert(tableVocabulary, vocab.toMap());
  }

  Future<Vocabulary?> getVocabularyByWord(String word, String language) async {
    final db = await database;
    final maps = await db.query(
      tableVocabulary,
      where: 'word = ? AND language = ?',
      whereArgs: [word, language],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Vocabulary.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Vocabulary>> getAllVocabulary({String? language, int? minProficiency}) async {
    final db = await database;
    
    String? whereClause;
    List<dynamic>? whereArgs;

    if (language != null && minProficiency != null) {
      whereClause = 'language = ? AND proficiency >= ?';
      whereArgs = [language, minProficiency];
    } else if (language != null) {
      whereClause = 'language = ?';
      whereArgs = [language];
    } else if (minProficiency != null) {
      whereClause = 'proficiency >= ?';
      whereArgs = [minProficiency];
    }

    final maps = await db.query(
      tableVocabulary,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'last_reviewed DESC',
    );
    return maps.map((map) => Vocabulary.fromMap(map)).toList();
  }

  Future<List<Vocabulary>> getRecentlyLearnedWords({int limit = 10, String? language}) async {
    final db = await database;
    
    String? whereClause;
    List<dynamic>? whereArgs;

    if (language != null) {
      whereClause = 'language = ?';
      whereArgs = [language];
    }

    final maps = await db.query(
      tableVocabulary,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'first_seen DESC',
      limit: limit,
    );
    return maps.map((map) => Vocabulary.fromMap(map)).toList();
  }

  Future<int> updateVocabulary(Vocabulary vocab) async {
    final db = await database;
    return await db.update(
      tableVocabulary,
      vocab.toMap(),
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  Future<int> incrementReviewCount(int vocabId) async {
    final db = await database;
    return await db.rawUpdate('''
      UPDATE $tableVocabulary 
      SET review_count = review_count + 1, last_reviewed = ?
      WHERE id = ?
    ''', [DateTime.now().millisecondsSinceEpoch, vocabId]);
  }

  Future<int> updateProficiency(int vocabId, int newProficiency) async {
    final db = await database;
    return await db.update(
      tableVocabulary,
      {
        'proficiency': newProficiency.clamp(1, 5),
        'last_reviewed': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [vocabId],
    );
  }

  Future<int> getVocabularyCount({String? language}) async {
    final db = await database;
    
    String? whereClause;
    List<dynamic>? whereArgs;

    if (language != null) {
      whereClause = 'language = ?';
      whereArgs = [language];
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableVocabulary ${whereClause != null ? 'WHERE $whereClause' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== MISTAKE OPERATIONS ====================

  Future<int> logMistake(Mistake mistake) async {
    final db = await database;
    
    // Check if similar mistake already exists
    final existing = await db.query(
      tableMistakes,
      where: 'mistake_text = ? AND mastered = 0',
      whereArgs: [mistake.mistakeText],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Update existing mistake
      final existingMistake = Mistake.fromMap(existing.first);
      return await db.update(
        tableMistakes,
        {
          'occurrence_count': existingMistake.occurrenceCount + 1,
          'last_made': mistake.lastMade,
        },
        where: 'id = ?',
        whereArgs: [existingMistake.id],
      );
    }

    return await db.insert(tableMistakes, mistake.toMap());
  }

  Future<List<Mistake>> getRecentMistakes({int limit = 10, bool includeMastered = false}) async {
    final db = await database;
    
    String? whereClause;
    if (!includeMastered) {
      whereClause = 'mastered = 0';
    }

    final maps = await db.query(
      tableMistakes,
      where: whereClause,
      orderBy: 'occurrence_count DESC, last_made DESC',
      limit: limit,
    );
    return maps.map((map) => Mistake.fromMap(map)).toList();
  }

  Future<List<Mistake>> getMistakesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      tableMistakes,
      where: 'mistake_type = ? AND mastered = 0',
      whereArgs: [type],
      orderBy: 'occurrence_count DESC',
    );
    return maps.map((map) => Mistake.fromMap(map)).toList();
  }

  Future<int> markMistakeAsMastered(int mistakeId) async {
    final db = await database;
    return await db.update(
      tableMistakes,
      {'mastered': 1},
      where: 'id = ?',
      whereArgs: [mistakeId],
    );
  }

  Future<int> getMistakeCount({bool mastered = false}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableMistakes WHERE mastered = ?',
      [mastered ? 1 : 0],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== UTILITY OPERATIONS ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete(tableUserProfile);
    await db.delete(tableChatMessages);
    await db.delete(tableVocabulary);
    await db.delete(tableMistakes);
  }

  /// Get database statistics for debugging
  Future<Map<String, int>> getStats() async {
    return {
      'messages': await getMessageCount(),
      'vocabulary': await getVocabularyCount(),
      'activeMistakes': await getMistakeCount(mastered: false),
      'masteredMistakes': await getMistakeCount(mastered: true),
    };
  }
}
