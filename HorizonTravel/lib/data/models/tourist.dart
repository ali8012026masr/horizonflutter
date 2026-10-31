class Tourist {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? status;
  final int? loyaltyPoints;

  Tourist({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.status,
    this.loyaltyPoints,
  });

  factory Tourist.fromJson(Map<String, dynamic> json) {
    return Tourist(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String?,
      loyaltyPoints: json['loyaltyPoints'] is num
          ? (json['loyaltyPoints'] as num).toInt()
          : int.tryParse(json['loyaltyPoints']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'status': status,
        'loyaltyPoints': loyaltyPoints,
      };
}

class RegisterTouristRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phone;
  final String? address;

  RegisterTouristRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'password': password,
    };
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (address != null && address!.isNotEmpty) map['address'] = address;
    return map;
  }
}

class UpdateTouristRequest {
  final String? fullName;
  final String? phone;
  final String? address;

  UpdateTouristRequest({this.fullName, this.phone, this.address});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['fullName'] = fullName;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    return map;
  }
}
