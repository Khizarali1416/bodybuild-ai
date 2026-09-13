import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  
  // Optional: keep track of context for API
  List<Map<String, dynamic>> get _apiHistory {
    return _messages.map((m) => {
      'role': m.role == MessageRole.user ? 'user' : 'model',
      'parts': [{'text': m.text}],
    }).toList();
  }

  void clearConversation() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> regenerateLastResponse() async {
    if (_isLoading || _messages.isEmpty) return;

    // Find the last AI message and the user message before it
    final lastAiIndex = _messages.lastIndexWhere((m) => m.role == MessageRole.ai);
    if (lastAiIndex == -1) return;

    // The user message should be the one right before the AI message
    final lastUserIndex = lastAiIndex - 1;
    if (lastUserIndex < 0 || _messages[lastUserIndex].role != MessageRole.user) return;

    final userMessageText = _messages[lastUserIndex].text;
    final aiMessageId = _messages[lastAiIndex].id;

    // Clear the current AI message text and set loading state
    _messages[lastAiIndex] = _messages[lastAiIndex].copyWith(text: '');
    _isLoading = true;
    notifyListeners();

    // Prepare history up to the last user message
    final historyToSend = _apiHistory.sublist(0, lastUserIndex);

    try {
      final stream = _apiService.streamChat(userMessageText, historyToSend);
      
      await for (final chunk in stream) {
        final index = _messages.indexWhere((m) => m.id == aiMessageId);
        if (index != -1) {
          final currentText = _messages[index].text;
          _messages[index] = _messages[index].copyWith(text: currentText + chunk);
          notifyListeners();
        }
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == aiMessageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(text: '[An error occurred]');
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      role: MessageRole.user,
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    final aiMessageId = const Uuid().v4();
    final aiMessage = ChatMessage(
      id: aiMessageId,
      text: '',
      role: MessageRole.ai,
    );
    _messages.add(aiMessage);
    
    // Copy history before sending so the new empty AI message isn't sent
    final historyToSend = _apiHistory.sublist(0, _apiHistory.length - 1);

    try {
      final stream = _apiService.streamChat(text, historyToSend);
      
      await for (final chunk in stream) {
        final index = _messages.indexWhere((m) => m.id == aiMessageId);
        if (index != -1) {
          final currentText = _messages[index].text;
          _messages[index] = _messages[index].copyWith(text: currentText + chunk);
          notifyListeners();
        }
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == aiMessageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(text: '[An error occurred]');
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
