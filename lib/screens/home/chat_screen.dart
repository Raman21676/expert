import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../vocabulary/vocabulary_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/typing_indicator.dart';

/// Chat Screen
/// 
/// Main interface for interacting with the AI tutor
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final chatProvider = context.read<ChatProvider>();
    final userProvider = context.read<UserProvider>();

    // Load chat history
    await chatProvider.loadChatHistory();

    // Initialize LLM if not already done
    if (!chatProvider.isInitializing && !chatProvider.messages.any((m) => m.role == 'assistant')) {
      await chatProvider.initializeLLM();
      
      // Send welcome message if first time
      if (chatProvider.messages.isEmpty && mounted) {
        final profile = userProvider.profile;
        if (profile != null) {
          final welcomeMsg = 'Hello ${profile.name}! 👋 I\'m your personal '
              '${profile.targetLanguage} tutor. Let\'s start learning together! '
              'What would you like to learn today?';
          
          // Add welcome message directly (not through LLM to save resources)
          // This is handled in the provider
        }
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();

    _messageController.clear();
    _scrollToBottom();

    if (userProvider.profile != null) {
      await chatProvider.sendMessage(
        text,
        profile: userProvider.profile!,
      );
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('LingoNative AI'),
            if (userProvider.profile != null)
              Text(
                'Learning ${userProvider.targetLanguage}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VocabularyScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading indicator
          if (chatProvider.isInitializing)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading AI model...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),

          // Error banner
          if (chatProvider.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chatProvider.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => chatProvider.clearError(),
                    color: Colors.red[700],
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length +
                        (chatProvider.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Typing indicator
                      if (index == chatProvider.messages.length) {
                        return const TypingIndicator();
                      }

                      final message = chatProvider.messages[index];
                      return ChatBubble(
                        message: message,
                        isUser: message.role == 'user',
                      );
                    },
                  ),
          ),

          // Message input
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about your target language',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 32),
          // Suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Hello! How are you?'),
              _buildSuggestionChip('Teach me basic greetings'),
              _buildSuggestionChip('How do I say "thank you"?'),
              _buildSuggestionChip('Explain verb conjugation'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                enabled: !chatProvider(context).isInitializing,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: chatProvider(context).isInitializing ? null : _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get chat provider in build method
  ChatProvider chatProvider(BuildContext context) {
    return context.read<ChatProvider>();
  }

  void _showNotImplementedSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
