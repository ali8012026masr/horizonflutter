class Payment {
  final int? id;
  final int? bookingId;
  final int? guideBookingId;
  final double? amount;
  final String? method;
  final String? status;
  final String? transactionDate;

  Payment({
    this.id,
    this.bookingId,
    this.guideBookingId,
    this.amount,
    this.method,
    this.status,
    this.transactionDate,
  });

  String? get paymentMethod => method;
  String? get paymentDate => transactionDate;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      bookingId: json['bookingId'] is num
          ? (json['bookingId'] as num).toInt()
          : int.tryParse(json['bookingId']?.toString() ?? ''),
      guideBookingId: json['guideBookingId'] is num
          ? (json['guideBookingId'] as num).toInt()
          : int.tryParse(json['guideBookingId']?.toString() ?? ''),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0.0'),
      method: json['method'] as String? ?? json['paymentMethod'] as String?,
      status: json['status'] as String?,
      transactionDate: json['transactionDate'] as String? ?? json['paymentDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'guideBookingId': guideBookingId,
        'amount': amount,
        'method': method,
        'status': status,
        'transactionDate': transactionDate,
      };
}

class PaymentRequest {
  final int? bookingId;
  final int? guideBookingId;
  final double amount;
  final String method;

  PaymentRequest({
    this.bookingId,
    this.guideBookingId,
    required this.amount,
    String? method,
    String? paymentMethod,
  }) : method = method ?? paymentMethod ?? 'CASH';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'method': method,
    };
    if (bookingId != null) map['bookingId'] = bookingId;
    if (guideBookingId != null) map['guideBookingId'] = guideBookingId;
    return map;
  }
}
