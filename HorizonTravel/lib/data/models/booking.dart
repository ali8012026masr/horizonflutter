class Booking {
  final int? id;
  final int? touristId;
  final int? serviceSlotId;
  final String? bookingDate;
  final String? status;
  final double? totalAmount;
  final String? paymentStatus;

  Booking({
    this.id,
    this.touristId,
    this.serviceSlotId,
    this.bookingDate,
    this.status,
    this.totalAmount,
    this.paymentStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      touristId: json['touristId'] is num
          ? (json['touristId'] as num).toInt()
          : int.tryParse(json['touristId']?.toString() ?? ''),
      serviceSlotId: json['serviceSlotId'] is num
          ? (json['serviceSlotId'] as num).toInt()
          : int.tryParse(json['serviceSlotId']?.toString() ?? ''),
      bookingDate: json['bookingDate'] as String?,
      status: json['status'] as String?,
      totalAmount: json['totalAmount'] is num
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount']?.toString() ?? '0.0'),
      paymentStatus: json['paymentStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'touristId': touristId,
        'serviceSlotId': serviceSlotId,
        'bookingDate': bookingDate,
        'status': status,
        'totalAmount': totalAmount,
        'paymentStatus': paymentStatus,
      };
}

class BookingRequest {
  final int touristId;
  final int serviceSlotId;

  BookingRequest({
    required this.touristId,
    required this.serviceSlotId,
  });

  Map<String, dynamic> toJson() => {
        'touristId': touristId,
        'serviceSlotId': serviceSlotId,
      };
}

class StatusRequest {
  final String status;

  StatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}
