class Guide {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? status;
  final String? nationalId;
  final String? bio;
  final double? ratingAvg;
  final int? ratingCount;
  final bool? isAvailable;
  final String? verificationStatus;
  final String? rejectionReason;
  final List<String>? languages;
  final String? location;
  final int? experienceYears;
  final double? defaultPrice;
  final bool negotiable;

  Guide({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.status,
    this.nationalId,
    this.bio,
    this.ratingAvg,
    this.ratingCount,
    bool? isAvailable,
    bool? available,
    this.verificationStatus,
    this.rejectionReason,
    this.languages,
    this.location,
    this.experienceYears,
    this.defaultPrice,
    bool? negotiable,
  })  : isAvailable = isAvailable ?? available,
        negotiable = negotiable ?? false;

  bool get available => isAvailable ?? true;

  factory Guide.fromJson(Map<String, dynamic> json) {
    List<String>? langs;
    if (json['languages'] is List) {
      langs = (json['languages'] as List).map((e) => e.toString()).toList();
    }

    final availableVal = json['isAvailable'] ?? json['available'];
    final negVal = json['negotiable'] ?? json['isNegotiated'];

    return Guide(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String?,
      nationalId: json['nationalId'] as String?,
      bio: json['bio'] as String?,
      ratingAvg: json['ratingAvg'] is num
          ? (json['ratingAvg'] as num).toDouble()
          : double.tryParse(json['ratingAvg']?.toString() ?? '0.0'),
      ratingCount: json['ratingCount'] is num
          ? (json['ratingCount'] as num).toInt()
          : int.tryParse(json['ratingCount']?.toString() ?? '0'),
      isAvailable: availableVal is bool ? availableVal : (availableVal?.toString() == 'true'),
      verificationStatus: json['verificationStatus'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      languages: langs,
      location: json['location'] as String?,
      experienceYears: json['experienceYears'] is num
          ? (json['experienceYears'] as num).toInt()
          : int.tryParse(json['experienceYears']?.toString() ?? ''),
      defaultPrice: json['defaultPrice'] is num
          ? (json['defaultPrice'] as num).toDouble()
          : double.tryParse(json['defaultPrice']?.toString() ?? ''),
      negotiable: negVal is bool ? negVal : (negVal?.toString() == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'status': status,
        'nationalId': nationalId,
        'bio': bio,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'isAvailable': isAvailable,
        'verificationStatus': verificationStatus,
        'rejectionReason': rejectionReason,
        'languages': languages,
        'location': location,
        'experienceYears': experienceYears,
        'defaultPrice': defaultPrice,
        'negotiable': negotiable,
      };
}

class RegisterGuideRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phone;
  final String? address;
  final String? nationalId;
  final String? bio;
  final List<String>? languages;
  final String? location;
  final int? experienceYears;
  final double? defaultPrice;
  final bool? negotiable;

  RegisterGuideRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    this.nationalId,
    this.bio,
    this.languages,
    this.location,
    this.experienceYears,
    this.defaultPrice,
    this.negotiable,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'password': password,
    };
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (address != null && address!.isNotEmpty) map['address'] = address;
    if (nationalId != null && nationalId!.isNotEmpty) map['nationalId'] = nationalId;
    if (bio != null && bio!.isNotEmpty) map['bio'] = bio;
    if (languages != null) map['languages'] = languages;
    if (location != null && location!.isNotEmpty) map['location'] = location;
    if (experienceYears != null) map['experienceYears'] = experienceYears;
    if (defaultPrice != null) map['defaultPrice'] = defaultPrice;
    if (negotiable != null) map['negotiable'] = negotiable;
    return map;
  }
}

class UpdateGuideRequest {
  final String? fullName;
  final String? phone;
  final String? address;
  final String? bio;
  final bool? isAvailable;
  final List<String>? languages;
  final String? location;
  final int? experienceYears;
  final double? defaultPrice;
  final bool? negotiable;

  UpdateGuideRequest({
    this.fullName,
    this.phone,
    this.address,
    this.bio,
    bool? isAvailable,
    bool? available,
    this.languages,
    this.location,
    this.experienceYears,
    this.defaultPrice,
    this.negotiable,
  }) : isAvailable = isAvailable ?? available;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['fullName'] = fullName;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (bio != null) map['bio'] = bio;
    if (isAvailable != null) map['isAvailable'] = isAvailable;
    if (languages != null) map['languages'] = languages;
    if (location != null) map['location'] = location;
    if (experienceYears != null) map['experienceYears'] = experienceYears;
    if (defaultPrice != null) map['defaultPrice'] = defaultPrice;
    if (negotiable != null) map['negotiable'] = negotiable;
    return map;
  }
}
