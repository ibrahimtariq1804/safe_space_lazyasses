class ChatMessage {
  final String id;
  final String message;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isMe,
    required this.timestamp,
  });
}

