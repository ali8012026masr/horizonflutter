class ServiceSlot {
  final int? id;
  final int? providerId;
  final String? providerBusinessName;
  final String? category;
  final String? origin;
  final String? destination;
  final String? locationName;
  final String? startDateTime;
  final String? endDateTime;
  final int? capacity;
  final int? availableSeats;
  final double? price;
  final String? status;
  final double? providerRatingAvg;
  final int? providerRatingCount;

  // Custom optional fields for caller compatibility
  final String? _customTitle;
  final String? _customDescription;
  final int? _customDurationMinutes;
  final String? _customLocation;
  final String? _customCancellationPolicy;

  ServiceSlot({
    this.id,
    this.providerId,
    this.providerBusinessName,
    this.category,
    this.origin,
    this.destination,
    this.locationName,
    this.startDateTime,
    this.endDateTime,
    this.capacity,
    this.availableSeats,
    this.price,
    this.status,
    this.providerRatingAvg,
    this.providerRatingCount,
    String? title,
    String? description,
    int? durationMinutes,
    String? location,
    String? cancellationPolicy,
  })  : _customTitle = title,
        _customDescription = description,
        _customDurationMinutes = durationMinutes,
        _customLocation = location,
        _customCancellationPolicy = cancellationPolicy;

  String get title =>
      _customTitle ??
      providerBusinessName ??
      locationName ??
      (origin != null && destination != null ? '$origin to $destination' : 'Service #${id ?? 0}');

  String get description =>
      _customDescription ??
      (origin != null && destination != null ? '$origin → $destination' : (locationName ?? category ?? ''));

  String get location => _customLocation ?? locationName ?? destination ?? origin ?? '';

  String get cancellationPolicy => _customCancellationPolicy ?? 'Standard 24h cancellation policy';

  int get durationMinutes {
    if (_customDurationMinutes != null) return _customDurationMinutes!;
    if (startDateTime != null && endDateTime != null) {
      try {
        final start = DateTime.parse(startDateTime!);
        final end = DateTime.parse(endDateTime!);
        final diff = end.difference(start).inMinutes;
        if (diff > 0) return diff;
      } catch (_) {}
    }
    return 60;
  }

  factory ServiceSlot.fromJson(Map<String, dynamic> json) {
    return ServiceSlot(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      providerId: json['providerId'] is num
          ? (json['providerId'] as num).toInt()
          : int.tryParse(json['providerId']?.toString() ?? ''),
      providerBusinessName: json['providerBusinessName'] as String?,
      category: json['category'] as String?,
      origin: json['origin'] as String?,
      destination: json['destination'] as String?,
      locationName: json['locationName'] as String?,
      startDateTime: json['startDateTime'] as String?,
      endDateTime: json['endDateTime'] as String?,
      capacity: json['capacity'] is num
          ? (json['capacity'] as num).toInt()
          : int.tryParse(json['capacity']?.toString() ?? '0'),
      availableSeats: json['availableSeats'] is num
          ? (json['availableSeats'] as num).toInt()
          : int.tryParse(json['availableSeats']?.toString() ?? '0'),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0.0'),
      status: json['status'] as String?,
      providerRatingAvg: json['providerRatingAvg'] is num
          ? (json['providerRatingAvg'] as num).toDouble()
          : double.tryParse(json['providerRatingAvg']?.toString() ?? '0.0'),
      providerRatingCount: json['providerRatingCount'] is num
          ? (json['providerRatingCount'] as num).toInt()
          : int.tryParse(json['providerRatingCount']?.toString() ?? '0'),
      title: json['title'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'providerBusinessName': providerBusinessName,
        'category': category,
        'origin': origin,
        'destination': destination,
        'locationName': locationName,
        'startDateTime': startDateTime,
        'endDateTime': endDateTime,
        'capacity': capacity,
        'availableSeats': availableSeats,
        'price': price,
        'status': status,
        'providerRatingAvg': providerRatingAvg,
        'providerRatingCount': providerRatingCount,
      };
}

class CreateServiceSlotRequest {
  final int providerId;
  final String category;
  final String? origin;
  final String? destination;
  final String? locationName;
  final String startDateTime;
  final String endDateTime;
  final int capacity;
  final double price;

  CreateServiceSlotRequest({
    int? providerId,
    int? serviceProviderId,
    required this.category,
    this.origin,
    this.destination,
    String? locationName,
    String? location,
    String? title,
    String? description,
    int? durationMinutes,
    String? cancellationPolicy,
    required this.startDateTime,
    required this.endDateTime,
    required this.capacity,
    required this.price,
  })  : providerId = providerId ?? serviceProviderId ?? 0,
        locationName = locationName ?? location ?? title;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'providerId': providerId,
      'category': category,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'capacity': capacity,
      'price': price,
    };
    if (origin != null && origin!.isNotEmpty) map['origin'] = origin;
    if (destination != null && destination!.isNotEmpty) map['destination'] = destination;
    if (locationName != null && locationName!.isNotEmpty) map['locationName'] = locationName;
    return map;
  }
}

class UpdateServiceSlotRequest {
  final String? origin;
  final String? destination;
  final String? locationName;
  final String? startDateTime;
  final String? endDateTime;
  final int? capacity;
  final double? price;
  final String? status;

  UpdateServiceSlotRequest({
    this.origin,
    this.destination,
    String? locationName,
    String? location,
    String? title,
    String? description,
    int? durationMinutes,
    String? cancellationPolicy,
    this.startDateTime,
    this.endDateTime,
    this.capacity,
    this.price,
    this.status,
  }) : locationName = locationName ?? location ?? title;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (origin != null) map['origin'] = origin;
    if (destination != null) map['destination'] = destination;
    if (locationName != null) map['locationName'] = locationName;
    if (startDateTime != null) map['startDateTime'] = startDateTime;
    if (endDateTime != null) map['endDateTime'] = endDateTime;
    if (capacity != null) map['capacity'] = capacity;
    if (price != null) map['price'] = price;
    if (status != null) map['status'] = status;
    return map;
  }
}
