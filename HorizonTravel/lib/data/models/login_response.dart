class LoginResponse {
  final int? id;
  final String? fullName;
  final String? email;
  final String? role;
  final Map<String, dynamic>? roleDetails;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresInSeconds;

  LoginResponse({
    this.id,
    this.fullName,
    this.email,
    this.role,
    this.roleDetails,
    this.accessToken,
    this.refreshToken,
    this.expiresInSeconds,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? details;
    if (json['roleDetails'] is Map<String, dynamic>) {
      details = json['roleDetails'] as Map<String, dynamic>;
    }

    return LoginResponse(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      roleDetails: details,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresInSeconds: json['expiresInSeconds'] is num
          ? (json['expiresInSeconds'] as num).toInt()
          : int.tryParse(json['expiresInSeconds']?.toString() ?? ''),
    );
  }

  String? get status {
    if (roleDetails != null && roleDetails!['status'] != null) {
      return roleDetails!['status'].toString();
    }
    return null;
  }

  String? get verificationStatus {
    if (roleDetails != null && roleDetails!['verificationStatus'] != null) {
      return roleDetails!['verificationStatus'].toString();
    }
    return null;
  }

  String? get rejectionReason {
    if (roleDetails != null && roleDetails!['rejectionReason'] != null) {
      return roleDetails!['rejectionReason'].toString();
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role,
        'roleDetails': roleDetails,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresInSeconds': expiresInSeconds,
      };
}
