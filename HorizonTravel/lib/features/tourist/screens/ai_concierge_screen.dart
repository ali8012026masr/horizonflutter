import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/ai_chat_models.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';
import 'slot_detail_screen.dart';

class AiChatItem {
  final bool isUser;
  final String text;
  final String? actionType;
  final String? actionPayloadJson;
  final bool isError;

  AiChatItem({
    required this.isUser,
    required this.text,
    this.actionType,
    this.actionPayloadJson,
    this.isError = false,
  });
}

class AiConciergeScreen extends StatefulWidget {
  const AiConciergeScreen({super.key});

  @override
  State<AiConciergeScreen> createState() => _AiConciergeScreenState();
}

class _AiConciergeScreenState extends State<AiConciergeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiChatMessage> _history = [];
  final List<AiChatItem> _messages = [];

  bool _isThinking = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _messages.add(
      AiChatItem(
        isUser: false,
        text: 'Hello! I am your Horizon Travel Concierge. I can help you plan trips, recommend top spots, find experienced tour guides, or find exciting group travels. How may I help you today?',
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final text = _textController.text.trim();
    if (text.isEmpty || text.length > 1000 || _isThinking) return;

    setState(() {
      _messages.add(AiChatItem(isUser: true, text: text));
      _isThinking = true;
      _textController.clear();
      _charCount = 0;
    });
    _scrollToBottom();

    // Cap history to last 12 turns
    final historyToSend = _history.length > 12
        ? _history.sublist(_history.length - 12)
        : List<AiChatMessage>.from(_history);

    _history.add(AiChatMessage(role: 'user', content: text));

    try {
      final req = AiChatRequest(message: text, history: historyToSend);
      final res = await _apiService.chatWithAi(req);

      if (mounted) {
        final reply = res.replyText ?? 'I received an empty response. Please ask again.';
        setState(() {
          _isThinking = false;
          _messages.add(AiChatItem(
            isUser: false,
            text: reply,
            actionType: res.actionType,
            actionPayloadJson: res.actionPayloadJson,
          ));
        });
        _history.add(AiChatMessage(role: 'assistant', content: reply));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Unable to connect to AI concierge. Please try again.';
        if (e.toString().contains('429')) {
          errorMsg = 'AI rate limit exceeded. Please wait a moment before sending another prompt.';
        } else {
          errorMsg = 'Error: $e';
        }

        setState(() {
          _isThinking = false;
          _messages.add(AiChatItem(
            isUser: false,
            text: errorMsg,
            isError: true,
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _handleAction(String actionType, String? payloadJson) {
    if (payloadJson == null || payloadJson.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payloadJson);
      if (actionType == AiActionType.recommendBundle || data.containsKey('slotId')) {
        final slotId = data['slotId'] is num ? (data['slotId'] as num).toInt() : int.tryParse(data['slotId']?.toString() ?? '');
        if (slotId != null && slotId > 0) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SlotDetailScreen(slotId: slotId),
            ),
          );
          return;
        }
      }
    } catch (_) {}

    // Fallback info snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action: $actionType. Please explore available slots.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.accent, size: 22),
            SizedBox(width: 8),
            Text('AI Concierge'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isThinking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI Concierge is thinking...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiChatItem item) {
    final isUser = item.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: item.isError ? AppColors.error : AppColors.primary,
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : (item.isError
                            ? AppColors.error.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: item.isError
                          ? AppColors.error
                          : (isUser ? AppColors.primary : AppColors.cardBorder),
                    ),
                  ),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (item.isError ? AppColors.error : null),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                if (!isUser && item.actionType != null && item.actionType!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ActionChip(
                    avatar: const Icon(Icons.explore_outlined, size: 16),
                    label: Text(_formatActionLabel(item.actionType!)),
                    onPressed: () => _handleAction(item.actionType!, item.actionPayloadJson),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  String _formatActionLabel(String actionType) {
    switch (actionType) {
      case AiActionType.filterSlots:
        return 'View Matching Services';
      case AiActionType.recommendBundle:
        return 'View Recommended Spot';
      case AiActionType.browseGuides:
        return 'Browse Guides';
      default:
        return 'Explore Options';
    }
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: 4,
                      minLines: 1,
                      maxLength: 1000,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      onChanged: (val) => setState(() => _charCount = val.length),
                      decoration: InputDecoration(
                        hintText: 'Ask about tours, destinations, guides...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isThinking || _charCount == 0 || _charCount > 1000 ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 56, top: 2),
                  child: Text(
                    '$_charCount / 1000',
                    style: TextStyle(
                      fontSize: 11,
                      color: _charCount > 1000 ? AppColors.coralAccent : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
