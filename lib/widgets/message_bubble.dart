import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRegenerate;

  const MessageBubble({
    super.key, 
    required this.message,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final chatTheme = theme.extension<ChatThemeExtension>()!;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isUser ? chatTheme.userBubbleColor : chatTheme.aiBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: chatTheme.aiTextColor?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BodyBuild AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: chatTheme.aiTextColor?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (isUser)
              Text(
                message.text,
                style: TextStyle(
                  color: chatTheme.userTextColor,
                  fontSize: 16,
                ),
              )
            else
              MarkdownBody(
                data: message.text.isEmpty ? '...' : message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: chatTheme.aiTextColor, fontSize: 16),
                  h1: TextStyle(color: chatTheme.aiTextColor, fontSize: 24, fontWeight: FontWeight.bold),
                  h2: TextStyle(color: chatTheme.aiTextColor, fontSize: 22, fontWeight: FontWeight.bold),
                  h3: TextStyle(color: chatTheme.aiTextColor, fontSize: 20, fontWeight: FontWeight.bold),
                  listBullet: TextStyle(color: chatTheme.aiTextColor),
                  code: TextStyle(
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.black12,
                    color: chatTheme.aiTextColor,
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (!isUser && message.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: message.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.copy,
                          size: 16,
                          color: chatTheme.aiTextColor?.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    if (onRegenerate != null) ...[
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: onRegenerate,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.refresh,
                            size: 18,
                            color: chatTheme.aiTextColor?.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
