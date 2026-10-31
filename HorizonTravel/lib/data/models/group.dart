class Group {
  final int? id;
  final String? groupName;
  final int? createdByTouristId;
  final String? joinCode;
  final int? bookingId;
  final String? createdAt;
  final List<GroupMember> members;

  Group({
    this.id,
    this.groupName,
    this.createdByTouristId,
    this.joinCode,
    this.bookingId,
    this.createdAt,
    this.members = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    var memberList = <GroupMember>[];
    if (json['members'] is List) {
      memberList = (json['members'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => GroupMember.fromJson(e))
          .toList();
    }

    return Group(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      groupName: json['groupName'] as String?,
      createdByTouristId: json['createdByTouristId'] is num
          ? (json['createdByTouristId'] as num).toInt()
          : int.tryParse(json['createdByTouristId']?.toString() ?? ''),
      joinCode: json['joinCode'] as String?,
      bookingId: json['bookingId'] is num
          ? (json['bookingId'] as num).toInt()
          : int.tryParse(json['bookingId']?.toString() ?? ''),
      createdAt: json['createdAt'] as String?,
      members: memberList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupName': groupName,
        'createdByTouristId': createdByTouristId,
        'joinCode': joinCode,
        'bookingId': bookingId,
        'createdAt': createdAt,
        'members': members.map((e) => e.toJson()).toList(),
      };
}

class GroupMember {
  final int? id;
  final int? touristId;
  final String? touristName;
  final String? status;
  final String? joinedAt;
  final double? amountOwed;
  final bool? paid;
  final String? phone;

  GroupMember({
    this.id,
    this.touristId,
    this.touristName,
    this.status,
    this.joinedAt,
    this.amountOwed,
    this.paid,
    this.phone,
  });

  String? get fullName => touristName;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final paidVal = json['paid'];
    return GroupMember(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      touristId: json['touristId'] is num
          ? (json['touristId'] as num).toInt()
          : int.tryParse(json['touristId']?.toString() ?? ''),
      touristName: json['touristName'] as String?,
      status: json['status'] as String?,
      joinedAt: json['joinedAt'] as String?,
      amountOwed: json['amountOwed'] is num
          ? (json['amountOwed'] as num).toDouble()
          : double.tryParse(json['amountOwed']?.toString() ?? '0.0'),
      paid: paidVal is bool ? paidVal : (paidVal?.toString() == 'true'),
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'touristId': touristId,
        'touristName': touristName,
        'status': status,
        'joinedAt': joinedAt,
        'amountOwed': amountOwed,
        'paid': paid,
        'phone': phone,
      };
}

class GroupMessage {
  final int? id;
  final int? senderId;
  final String? senderName;
  final String? message;
  final String? sentAt;

  GroupMessage({
    this.id,
    this.senderId,
    this.senderName,
    this.message,
    this.sentAt,
  });

  String? get content => message;

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      senderId: json['senderId'] is num
          ? (json['senderId'] as num).toInt()
          : int.tryParse(json['senderId']?.toString() ?? ''),
      senderName: json['senderName'] as String?,
      message: (json['message'] ?? json['content']) as String?,
      sentAt: json['sentAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'sentAt': sentAt,
      };
}

class GroupCreateRequest {
  final String groupName;
  final int createdByTouristId;

  GroupCreateRequest({
    required this.groupName,
    int? createdByTouristId,
    int? touristId,
  }) : createdByTouristId = createdByTouristId ?? touristId ?? 0;

  Map<String, dynamic> toJson() => {
        'groupName': groupName,
        'createdByTouristId': createdByTouristId,
      };
}

class JoinGroupRequest {
  final String joinCode;
  final int touristId;

  JoinGroupRequest({
    required this.joinCode,
    required this.touristId,
  });

  Map<String, dynamic> toJson() => {
        'joinCode': joinCode,
        'touristId': touristId,
      };
}

class GroupBookingRequest {
  final int bookingId;

  GroupBookingRequest({required this.bookingId});

  Map<String, dynamic> toJson() => {'bookingId': bookingId};
}

class MessageRequest {
  final int touristId;
  final String message;

  MessageRequest({
    int? touristId,
    int? senderId,
    String? senderName,
    String? message,
    String? content,
  })  : touristId = touristId ?? senderId ?? 0,
        message = message ?? content ?? '';

  Map<String, dynamic> toJson() => {
        'touristId': touristId,
        'message': message,
      };
}
