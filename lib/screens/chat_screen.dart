import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _focusNode.requestFocus();
    
    final provider = context.read<ChatProvider>();
    provider.sendMessage(text).then((_) {
      _scrollToBottom();
    });
    
    // Initial scroll when message is sent
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
  }

  Widget _buildEmptyState() {
    final suggestions = [
      "How much protein do I need?",
      "Create a beginner muscle-building workout.",
      "Explain creatine.",
      "What are the risks of anabolic steroids?",
      "How does progressive overload work?",
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'BodyBuild AI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI companion for smarter training, nutrition & muscle growth.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            ...suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ActionChip(
                    label: Text(suggestion),
                    onPressed: () => _handleSubmitted(suggestion),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center),
            SizedBox(width: 8),
            Text('BodyBuild AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Conversation',
            onPressed: () {
              context.read<ChatProvider>().clearConversation();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (provider.messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Auto-scroll logic could be enhanced, simple version here
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (provider.isLoading) {
                       _scrollToBottom();
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      final isLastMessage = index == provider.messages.length - 1;
                      final isAiMessage = message.role == MessageRole.ai;
                      
                      return MessageBubble(
                        message: message,
                        onRegenerate: (isLastMessage && isAiMessage && !provider.isLoading)
                            ? () => provider.regenerateLastResponse()
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Ask about bodybuilding, nutrition, etc...',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              return Container(
                decoration: BoxDecoration(
                  color: provider.isLoading 
                      ? Colors.grey 
                      : Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: provider.isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleSubmitted(_textController.text),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
