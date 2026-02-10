import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../core/database/models/chat_message.dart';
import '../core/database/models/user_profile.dart';
import '../services/llm/llm_service.dart';
import '../services/llm/context_builder.dart';

/// Chat Provider
/// 
/// Manages chat state, message history, and AI generation
class ChatProvider with ChangeNotifier {
  final LLMService _llmService;
  final DatabaseHelper _db;
  final ContextBuilder _contextBuilder;

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isInitializing = false;
  String? _error;

  ChatProvider({
    LLMService? llmService,
    DatabaseHelper? db,
    ContextBuilder? contextBuilder,
  })  : _llmService = llmService ?? LLMService.instance,
        _db = db ?? DatabaseHelper.instance,
        _contextBuilder = contextBuilder ?? ContextBuilder();

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isInitializing => _isInitializing;
  String? get error => _error;

  /// Initialize the LLM service
  Future<void> initializeLLM() async {
    if (_llmService.isInitialized) return;

    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      await _llmService.initialize();
    } catch (e) {
      _error = 'Failed to load AI model: $e';
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Load chat history from database
  Future<void> loadChatHistory({int limit = 50}) async {
    try {
      _messages = await _db.getRecentMessages(limit: limit);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load chat history: $e';
      notifyListeners();
    }
  }

  /// Send a message and get AI response
  Future<void> sendMessage(
    String text, {
    required UserProfile profile,
    int maxTokens = 200,
  }) async {
    if (text.trim().isEmpty) return;

    _error = null;

    // Add user message
    final userMessage = ChatMessage(
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.insertMessage(userMessage);
    _messages.add(userMessage);
    notifyListeners();

    // Show typing indicator
    _isTyping = true;
    notifyListeners();

    try {
      // Ensure LLM is initialized
      if (!_llmService.isInitialized) {
        await initializeLLM();
      }

      // Build context prompt
      final prompt = await _contextBuilder.buildPrompt(
        profile: profile,
        userMessage: text.trim(),
      );

      // Generate response
      final response = await _llmService.generateResponse(
        prompt,
        maxTokens: maxTokens,
        temperature: 0.7,
      );

      // Add assistant message
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _db.insertMessage(assistantMessage);
      _messages.add(assistantMessage);

      // Compress old messages if needed
      await _db.compressOldMessages();

    } catch (e) {
      _error = 'Failed to get response: $e';
      
      // Add error message
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _messages.add(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// Send a simple message without full context (for quick responses)
  Future<void> sendSimpleMessage(
    String text, {
    required UserProfile profile,
  }) async {
    if (text.trim().isEmpty) return;

    _error = null;

    final userMessage = ChatMessage(
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.insertMessage(userMessage);
    _messages.add(userMessage);
    notifyListeners();

    _isTyping = true;
    notifyListeners();

    try {
      if (!_llmService.isInitialized) {
        await initializeLLM();
      }

      final prompt = _contextBuilder.buildSimplePrompt(
        profile: profile,
        userMessage: text.trim(),
      );

      final response = await _llmService.generateResponse(prompt);

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _db.insertMessage(assistantMessage);
      _messages.add(assistantMessage);

    } catch (e) {
      _error = 'Failed to get response: $e';
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// Clear chat history
  Future<void> clearHistory() async {
    await _db.clearAllMessages();
    _messages = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
