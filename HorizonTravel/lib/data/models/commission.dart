class Commission {
  final int? id;
  final int? bookingId;
  final String? providerName;
  final String? serviceCategory;
  final double? percentage;
  final double? amount;
  final String? calculatedDate;
  final String? settlementStatus;

  Commission({
    this.id,
    this.bookingId,
    this.providerName,
    this.serviceCategory,
    this.percentage,
    this.amount,
    this.calculatedDate,
    this.settlementStatus,
  });

  int? get providerId => null;
  double? get commissionAmount => amount;
  double? get commissionRate => percentage;
  String? get status => settlementStatus;
  String? get createdAt => calculatedDate;
  String? get settledAt => settlementStatus == 'SETTLED' ? calculatedDate : null;
  double? get bookingAmount => (percentage != null && percentage! > 0 && amount != null) ? (amount! / percentage!) : amount;

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      bookingId: json['bookingId'] is num
          ? (json['bookingId'] as num).toInt()
          : int.tryParse(json['bookingId']?.toString() ?? ''),
      providerName: json['providerName'] as String?,
      serviceCategory: json['serviceCategory'] as String?,
      percentage: json['percentage'] is num
          ? (json['percentage'] as num).toDouble()
          : double.tryParse(json['percentage']?.toString() ?? '0.0'),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0.0'),
      calculatedDate: json['calculatedDate'] as String?,
      settlementStatus: json['settlementStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'providerName': providerName,
        'serviceCategory': serviceCategory,
        'percentage': percentage,
        'amount': amount,
        'calculatedDate': calculatedDate,
        'settlementStatus': settlementStatus,
      };
}

class RevenueSummary {
  final double totalRevenue;
  final double totalCommission;
  final int paymentCount;

  RevenueSummary({
    this.totalRevenue = 0.0,
    this.totalCommission = 0.0,
    this.paymentCount = 0,
  });

  int get totalTransactions => paymentCount;

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      totalRevenue: json['totalRevenue'] is num
          ? (json['totalRevenue'] as num).toDouble()
          : double.tryParse(json['totalRevenue']?.toString() ?? '0.0') ?? 0.0,
      totalCommission: json['totalCommission'] is num
          ? (json['totalCommission'] as num).toDouble()
          : double.tryParse(json['totalCommission']?.toString() ?? '0.0') ?? 0.0,
      paymentCount: json['paymentCount'] is num
          ? (json['paymentCount'] as num).toInt()
          : int.tryParse(json['paymentCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalRevenue': totalRevenue,
        'totalCommission': totalCommission,
        'paymentCount': paymentCount,
      };
}

class BookingsSummary {
  final int totalBookings;
  final int pendingCount;
  final int confirmedCount;
  final int cancelledCount;
  final int completedCount;

  BookingsSummary({
    this.totalBookings = 0,
    this.pendingCount = 0,
    this.confirmedCount = 0,
    this.cancelledCount = 0,
    this.completedCount = 0,
  });

  int get confirmedBookings => confirmedCount;
  int get cancelledBookings => cancelledCount;

  factory BookingsSummary.fromJson(Map<String, dynamic> json) {
    return BookingsSummary(
      totalBookings: json['totalBookings'] is num
          ? (json['totalBookings'] as num).toInt()
          : int.tryParse(json['totalBookings']?.toString() ?? '0') ?? 0,
      pendingCount: json['pendingCount'] is num
          ? (json['pendingCount'] as num).toInt()
          : int.tryParse(json['pendingCount']?.toString() ?? '0') ?? 0,
      confirmedCount: json['confirmedCount'] is num
          ? (json['confirmedCount'] as num).toInt()
          : int.tryParse(json['confirmedCount']?.toString() ?? '0') ?? 0,
      cancelledCount: json['cancelledCount'] is num
          ? (json['cancelledCount'] as num).toInt()
          : int.tryParse(json['cancelledCount']?.toString() ?? '0') ?? 0,
      completedCount: json['completedCount'] is num
          ? (json['completedCount'] as num).toInt()
          : int.tryParse(json['completedCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalBookings': totalBookings,
        'pendingCount': pendingCount,
        'confirmedCount': confirmedCount,
        'cancelledCount': cancelledCount,
        'completedCount': completedCount,
      };
}

class CommissionSummary {
  final double totalCommission;
  final double pendingCommission;
  final double settledCommission;

  CommissionSummary({
    this.totalCommission = 0.0,
    this.pendingCommission = 0.0,
    this.settledCommission = 0.0,
  });

  factory CommissionSummary.fromJson(Map<String, dynamic> json) {
    return CommissionSummary(
      totalCommission: json['totalCommission'] is num
          ? (json['totalCommission'] as num).toDouble()
          : double.tryParse(json['totalCommission']?.toString() ?? '0.0') ?? 0.0,
      pendingCommission: json['pendingCommission'] is num
          ? (json['pendingCommission'] as num).toDouble()
          : double.tryParse(json['pendingCommission']?.toString() ?? '0.0') ?? 0.0,
      settledCommission: json['settledCommission'] is num
          ? (json['settledCommission'] as num).toDouble()
          : double.tryParse(json['settledCommission']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalCommission': totalCommission,
        'pendingCommission': pendingCommission,
        'settledCommission': settledCommission,
      };
}
