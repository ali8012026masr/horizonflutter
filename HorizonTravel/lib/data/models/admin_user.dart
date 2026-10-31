class AdminUser {
  final int? id;
  final String? fullName;
  final String? email;
  final String? role;
  final String? status;
  final String? createdAt;

  AdminUser({
    this.id,
    this.fullName,
    this.email,
    this.role,
    this.status,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role,
        'status': status,
        'createdAt': createdAt,
      };
}

class VerifyRequest {
  final bool approved;
  final String? rejectionReason;

  const VerifyRequest({
    required this.approved,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'approved': approved};
    if (rejectionReason != null && rejectionReason!.isNotEmpty) {
      map['rejectionReason'] = rejectionReason;
    }
    return map;
  }
}

class UpdateUserStatusRequest {
  final String status;

  UpdateUserStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}
