class LocationModel {
  final int? tourGuideId;
  final double? latitude;
  final double? longitude;
  final String? updatedAt;

  LocationModel({
    this.tourGuideId,
    this.latitude,
    this.longitude,
    this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      tourGuideId: json['tourGuideId'] is num
          ? (json['tourGuideId'] as num).toInt()
          : int.tryParse(json['tourGuideId']?.toString() ?? ''),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? '0.0'),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? '0.0'),
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tourGuideId': tourGuideId,
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': updatedAt,
      };
}

class UpdateLocationRequest {
  final double latitude;
  final double longitude;

  UpdateLocationRequest({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
