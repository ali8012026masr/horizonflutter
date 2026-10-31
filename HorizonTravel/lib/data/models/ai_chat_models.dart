class AiChatMessage {
  final String sender; // 'user' or 'assistant'
  final String text;

  AiChatMessage({
    String? sender,
    String? role,
    String? text,
    String? content,
  })  : sender = sender ?? role ?? 'user',
        text = text ?? content ?? '';

  String get role => sender;
  String get content => text;

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      sender: (json['sender'] ?? json['role']) as String? ?? 'user',
      text: (json['text'] ?? json['content']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
      };
}

class AiChatRequest {
  final String userMessage;
  final List<AiChatMessage> history;

  AiChatRequest({
    String? userMessage,
    String? message,
    this.history = const [],
  }) : userMessage = userMessage ?? message ?? '';

  Map<String, dynamic> toJson() => {
        'userMessage': userMessage,
        'history': history.map((e) => e.toJson()).toList(),
      };
}

class AiChatResponse {
  final String? replyText;
  final String? actionType;
  final String? actionPayloadJson;

  AiChatResponse({
    this.replyText,
    this.actionType,
    this.actionPayloadJson,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      replyText: json['replyText'] as String?,
      actionType: json['actionType'] as String?,
      actionPayloadJson: json['actionPayloadJson'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'replyText': replyText,
        'actionType': actionType,
        'actionPayloadJson': actionPayloadJson,
      };
}
