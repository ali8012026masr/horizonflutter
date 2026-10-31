class GuideAvailability {
  final int? id;
  final int? tourGuideId;
  final String? tourGuideName;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? notes;
  final String? status;
  final double? tourGuideRatingAvg;
  final int? tourGuideRatingCount;

  GuideAvailability({
    this.id,
    this.tourGuideId,
    this.tourGuideName,
    this.date,
    this.startTime,
    this.endTime,
    this.location,
    this.notes,
    this.status,
    this.tourGuideRatingAvg,
    this.tourGuideRatingCount,
  });

  factory GuideAvailability.fromJson(Map<String, dynamic> json) {
    return GuideAvailability(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      tourGuideId: json['tourGuideId'] is num
          ? (json['tourGuideId'] as num).toInt()
          : int.tryParse(json['tourGuideId']?.toString() ?? ''),
      tourGuideName: json['tourGuideName'] as String?,
      date: json['date'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String?,
      tourGuideRatingAvg: json['tourGuideRatingAvg'] is num
          ? (json['tourGuideRatingAvg'] as num).toDouble()
          : double.tryParse(json['tourGuideRatingAvg']?.toString() ?? '0.0'),
      tourGuideRatingCount: json['tourGuideRatingCount'] is num
          ? (json['tourGuideRatingCount'] as num).toInt()
          : int.tryParse(json['tourGuideRatingCount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tourGuideId': tourGuideId,
        'tourGuideName': tourGuideName,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'location': location,
        'notes': notes,
        'status': status,
        'tourGuideRatingAvg': tourGuideRatingAvg,
        'tourGuideRatingCount': tourGuideRatingCount,
      };
}

class CreateGuideAvailabilityRequest {
  final int tourGuideId;
  final String date;
  final String startTime;
  final String endTime;
  final String? location;
  final String? notes;

  CreateGuideAvailabilityRequest({
    required this.tourGuideId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'tourGuideId': tourGuideId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
    if (location != null && location!.isNotEmpty) map['location'] = location;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    return map;
  }
}

class UpdateGuideAvailabilityRequest {
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? notes;
  final String? status;

  UpdateGuideAvailabilityRequest({
    this.date,
    this.startTime,
    this.endTime,
    this.location,
    this.notes,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (date != null) map['date'] = date;
    if (startTime != null) map['startTime'] = startTime;
    if (endTime != null) map['endTime'] = endTime;
    if (location != null) map['location'] = location;
    if (notes != null) map['notes'] = notes;
    if (status != null) map['status'] = status;
    return map;
  }
}
