class Provider {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? status;
  final String? businessName;
  final String? tradeLicenseNo;
  final String? category;
  final String? verificationStatus;
  final String? rejectionReason;
  final double? commissionRate;
  final double? ratingAvg;
  final int? ratingCount;

  Provider({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.status,
    this.businessName,
    String? tradeLicenseNo,
    String? tradeLicense,
    this.category,
    this.verificationStatus,
    this.rejectionReason,
    this.commissionRate,
    this.ratingAvg,
    this.ratingCount,
  }) : tradeLicenseNo = tradeLicenseNo ?? tradeLicense;

  String? get tradeLicense => tradeLicenseNo;

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String?,
      businessName: json['businessName'] as String?,
      tradeLicenseNo: (json['tradeLicenseNo'] ?? json['tradeLicense']) as String?,
      category: json['category'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      commissionRate: json['commissionRate'] is num
          ? (json['commissionRate'] as num).toDouble()
          : double.tryParse(json['commissionRate']?.toString() ?? ''),
      ratingAvg: json['ratingAvg'] is num
          ? (json['ratingAvg'] as num).toDouble()
          : double.tryParse(json['ratingAvg']?.toString() ?? '0.0'),
      ratingCount: json['ratingCount'] is num
          ? (json['ratingCount'] as num).toInt()
          : int.tryParse(json['ratingCount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'status': status,
        'businessName': businessName,
        'tradeLicenseNo': tradeLicenseNo,
        'category': category,
        'verificationStatus': verificationStatus,
        'rejectionReason': rejectionReason,
        'commissionRate': commissionRate,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
      };
}

class RegisterProviderRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phone;
  final String? address;
  final String businessName;
  final String? tradeLicenseNo;
  final String? nationalId;
  final String? category;
  final double? commissionRate;

  RegisterProviderRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    required this.businessName,
    String? tradeLicenseNo,
    String? tradeLicense,
    this.nationalId,
    this.category,
    this.commissionRate,
  }) : tradeLicenseNo = tradeLicenseNo ?? tradeLicense;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'password': password,
      'businessName': businessName,
    };
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (address != null && address!.isNotEmpty) map['address'] = address;
    if (tradeLicenseNo != null && tradeLicenseNo!.isNotEmpty) map['tradeLicenseNo'] = tradeLicenseNo;
    if (nationalId != null && nationalId!.isNotEmpty) map['nationalId'] = nationalId;
    if (category != null && category!.isNotEmpty) map['category'] = category;
    if (commissionRate != null) map['commissionRate'] = commissionRate;
    return map;
  }
}

class UpdateProviderRequest {
  final String? fullName;
  final String? phone;
  final String? address;
  final String? businessName;
  final String? tradeLicenseNo;
  final String? category;
  final double? commissionRate;

  UpdateProviderRequest({
    this.fullName,
    this.phone,
    this.address,
    this.businessName,
    String? tradeLicenseNo,
    String? tradeLicense,
    this.category,
    this.commissionRate,
  }) : tradeLicenseNo = tradeLicenseNo ?? tradeLicense;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['fullName'] = fullName;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (businessName != null) map['businessName'] = businessName;
    if (tradeLicenseNo != null) map['tradeLicenseNo'] = tradeLicenseNo;
    if (category != null) map['category'] = category;
    if (commissionRate != null) map['commissionRate'] = commissionRate;
    return map;
  }
}
