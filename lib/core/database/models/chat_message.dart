/// Chat Message Model
/// Stores conversation history with compression support
class ChatMessage {
  final int? id;
  final String role; // 'user' or 'assistant'
  final String content;
  final int timestamp;
  final int? tokensUsed;
  final String? sessionId;
  final bool compressed;

  ChatMessage({
    this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.tokensUsed,
    this.sessionId,
    this.compressed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp,
      'tokens_used': tokensUsed,
      'session_id': sessionId,
      'compressed': compressed ? 1 : 0,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      role: map['role'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as int,
      tokensUsed: map['tokens_used'] as int?,
      sessionId: map['session_id'] as String?,
      compressed: map['compressed'] == 1,
    );
  }

  ChatMessage copyWith({
    int? id,
    String? role,
    String? content,
    int? timestamp,
    int? tokensUsed,
    String? sessionId,
    bool? compressed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      sessionId: sessionId ?? this.sessionId,
      compressed: compressed ?? this.compressed,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(role: $role, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., timestamp: $timestamp)';
  }
}
