class GuideRating {
  final int? id;
  final int? guideBookingId;
  final int? score;
  final String? comment;
  final String? ratedDate;

  GuideRating({
    this.id,
    this.guideBookingId,
    this.score,
    this.comment,
    this.ratedDate,
  });

  factory GuideRating.fromJson(Map<String, dynamic> json) {
    return GuideRating(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      guideBookingId: json['guideBookingId'] is num
          ? (json['guideBookingId'] as num).toInt()
          : int.tryParse(json['guideBookingId']?.toString() ?? ''),
      score: json['score'] is num
          ? (json['score'] as num).toInt()
          : int.tryParse(json['score']?.toString() ?? '5'),
      comment: json['comment'] as String?,
      ratedDate: json['ratedDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'guideBookingId': guideBookingId,
        'score': score,
        'comment': comment,
        'ratedDate': ratedDate,
      };
}

class GuideRatingRequest {
  final int guideBookingId;
  final int score;
  final String? comment;

  GuideRatingRequest({
    required this.guideBookingId,
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'guideBookingId': guideBookingId,
      'score': score,
    };
    if (comment != null && comment!.isNotEmpty) {
      map['comment'] = comment;
    }
    return map;
  }
}

class ServiceRating {
  final int? id;
  final int? bookingId;
  final int? touristId;
  final int? providerId;
  final int? score;
  final String? comment;
  final String? ratedDate;

  ServiceRating({
    this.id,
    this.bookingId,
    this.touristId,
    this.providerId,
    this.score,
    this.comment,
    this.ratedDate,
  });

  factory ServiceRating.fromJson(Map<String, dynamic> json) {
    return ServiceRating(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      bookingId: json['bookingId'] is num
          ? (json['bookingId'] as num).toInt()
          : int.tryParse(json['bookingId']?.toString() ?? ''),
      touristId: json['touristId'] is num
          ? (json['touristId'] as num).toInt()
          : int.tryParse(json['touristId']?.toString() ?? ''),
      providerId: json['providerId'] is num
          ? (json['providerId'] as num).toInt()
          : int.tryParse(json['providerId']?.toString() ?? ''),
      score: json['score'] is num
          ? (json['score'] as num).toInt()
          : int.tryParse(json['score']?.toString() ?? '5'),
      comment: json['comment'] as String?,
      ratedDate: json['ratedDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'touristId': touristId,
        'providerId': providerId,
        'score': score,
        'comment': comment,
        'ratedDate': ratedDate,
      };
}

class ServiceRatingRequest {
  final int bookingId;
  final int touristId;
  final int providerId;
  final int score;
  final String? comment;

  ServiceRatingRequest({
    required this.bookingId,
    required this.touristId,
    required this.providerId,
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'bookingId': bookingId,
      'touristId': touristId,
      'providerId': providerId,
      'score': score,
    };
    if (comment != null && comment!.isNotEmpty) {
      map['comment'] = comment;
    }
    return map;
  }
}
