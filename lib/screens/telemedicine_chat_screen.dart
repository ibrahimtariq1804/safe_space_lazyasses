import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

class TelemedicineChatScreen extends StatefulWidget {
  const TelemedicineChatScreen({Key? key}) : super(key: key);

  @override
  State<TelemedicineChatScreen> createState() => _TelemedicineChatScreenState();
}

class _TelemedicineChatScreenState extends State<TelemedicineChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      message: 'Hello! How can I help you today?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      id: '2',
      message: 'Hi Doctor, I have been experiencing headaches lately.',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    ),
    ChatMessage(
      id: '3',
      message:
          'I understand. Can you describe the type of pain and when it usually occurs?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    ChatMessage(
      id: '4',
      message: 'It\'s a throbbing pain, usually in the afternoon.',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().toString(),
            message: _messageController.text,
            isMe: true,
            timestamp: DateTime.now(),
          ),
        );
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl + 8,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.tealAccent.withValues(alpha: 0.1),
                  AppColors.deepCharcoal,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.tealAccent,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.graphite,
                    border: Border.all(
                      color: AppColors.success,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.tealAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Sarah Johnson',
                        style: AppTextStyles.h4.copyWith(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Online',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.video_call, size: 28),
                  onPressed: () {
                    _showCallDialog(context, 'video');
                  },
                  color: AppColors.tealAccent,
                ),
                IconButton(
                  icon: const Icon(Icons.call, size: 24),
                  onPressed: () {
                    _showCallDialog(context, 'audio');
                  },
                  color: AppColors.tealAccent,
                ),
              ],
            ),
          ),
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.graphite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment Button
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {},
                  ),

                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.deepCharcoal,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Send Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: AppColors.deepCharcoal,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.graphite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.tealAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type == 'video' ? Icons.video_call : Icons.call,
                  color: AppColors.tealAccent,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                type == 'video' ? 'Start Video Call?' : 'Start Audio Call?',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'Connect with Dr. Sarah Johnson',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Call feature coming soon!',
                      style: AppTextStyles.bodyMedium,
                    ),
                    backgroundColor: AppColors.tealAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Start Call',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.tealAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.graphite,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.tealAccent,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: message.isMe
                    ? AppColors.tealAccent
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusMd),
                  topRight: const Radius.circular(AppSpacing.radiusMd),
                  bottomLeft: message.isMe
                      ? const Radius.circular(AppSpacing.radiusMd)
                      : Radius.zero,
                  bottomRight: message.isMe
                      ? Radius.zero
                      : const Radius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                message.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: message.isMe
                      ? AppColors.deepCharcoal
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.graphite,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

