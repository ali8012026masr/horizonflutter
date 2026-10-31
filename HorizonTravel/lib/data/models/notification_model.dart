export 'location_model.dart';

class NotificationModel {
  final int? id;
  final String? message;
  final String? type;
  final bool read;
  final String? createdAt;

  NotificationModel({
    this.id,
    this.message,
    this.type,
    this.read = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final readVal = json['read'] ?? json['isRead'];
    return NotificationModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      message: json['message'] as String?,
      type: json['type'] as String?,
      read: readVal is bool ? readVal : (readVal?.toString() == 'true'),
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'type': type,
        'read': read,
        'createdAt': createdAt,
      };
}

class CountResponse {
  final int count;

  CountResponse({this.count = 0});

  factory CountResponse.fromJson(Map<String, dynamic> json) {
    return CountResponse(
      count: json['count'] is num ? (json['count'] as num).toInt() : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'count': count};
}

class MessageResponse {
  final String? message;

  MessageResponse({this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(message: json['message'] as String?);
  }

  Map<String, dynamic> toJson() => {'message': message};
}
