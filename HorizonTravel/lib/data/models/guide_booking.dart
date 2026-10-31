class GuideBooking {
  final int? id;
  final int? touristId;
  final int? tourGuideId;
  final int? guideAvailabilityId;
  final String? scheduleDate;
  final double? agreedPrice;
  final bool isNegotiated;
  final String? status;
  final bool paymentReceived;

  GuideBooking({
    this.id,
    this.touristId,
    this.tourGuideId,
    this.guideAvailabilityId,
    this.scheduleDate,
    this.agreedPrice,
    bool? isNegotiated,
    bool? negotiated,
    this.status,
    bool? paymentReceived,
  })  : isNegotiated = isNegotiated ?? negotiated ?? false,
        paymentReceived = paymentReceived ?? false;

  bool get negotiated => isNegotiated;

  factory GuideBooking.fromJson(Map<String, dynamic> json) {
    final negVal = json['isNegotiated'] ?? json['negotiated'];
    final paidVal = json['paymentReceived'];

    return GuideBooking(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      touristId: json['touristId'] is num
          ? (json['touristId'] as num).toInt()
          : int.tryParse(json['touristId']?.toString() ?? ''),
      tourGuideId: json['tourGuideId'] is num
          ? (json['tourGuideId'] as num).toInt()
          : int.tryParse(json['tourGuideId']?.toString() ?? ''),
      guideAvailabilityId: json['guideAvailabilityId'] is num
          ? (json['guideAvailabilityId'] as num).toInt()
          : int.tryParse(json['guideAvailabilityId']?.toString() ?? ''),
      scheduleDate: json['scheduleDate'] as String?,
      agreedPrice: json['agreedPrice'] is num
          ? (json['agreedPrice'] as num).toDouble()
          : double.tryParse(json['agreedPrice']?.toString() ?? '0.0'),
      isNegotiated: negVal is bool ? negVal : (negVal?.toString() == 'true'),
      status: json['status'] as String?,
      paymentReceived: paidVal is bool ? paidVal : (paidVal?.toString() == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'touristId': touristId,
        'tourGuideId': tourGuideId,
        'guideAvailabilityId': guideAvailabilityId,
        'scheduleDate': scheduleDate,
        'agreedPrice': agreedPrice,
        'isNegotiated': isNegotiated,
        'status': status,
        'paymentReceived': paymentReceived,
      };
}

class GuideBookingRequest {
  final int touristId;
  final int tourGuideId;
  final int? guideAvailabilityId;
  final String scheduleDate;
  final double agreedPrice;
  final bool isNegotiated;

  GuideBookingRequest({
    required this.touristId,
    int? tourGuideId,
    int? guideId,
    this.guideAvailabilityId,
    required this.scheduleDate,
    required this.agreedPrice,
    bool? isNegotiated,
    bool? negotiated,
    bool? negotiable,
  })  : tourGuideId = tourGuideId ?? guideId ?? 0,
        isNegotiated = isNegotiated ?? negotiated ?? negotiable ?? false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'touristId': touristId,
      'tourGuideId': tourGuideId,
      'scheduleDate': scheduleDate,
      'agreedPrice': agreedPrice,
      'isNegotiated': isNegotiated,
    };
    if (guideAvailabilityId != null) {
      map['guideAvailabilityId'] = guideAvailabilityId;
    }
    return map;
  }
}

class UpdateGuideBookingStatusRequest {
  final String status;

  UpdateGuideBookingStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}
