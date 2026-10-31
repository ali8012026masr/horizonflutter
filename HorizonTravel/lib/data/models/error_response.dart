class ErrorResponse {
  final String? timestamp;
  final int? status;
  final String? message;
  final Map<String, String>? errors;

  ErrorResponse({
    this.timestamp,
    this.status,
    this.message,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    Map<String, String>? errorMap;
    if (json['errors'] is Map) {
      errorMap = (json['errors'] as Map).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return ErrorResponse(
      timestamp: json['timestamp'] as String?,
      status: json['status'] is num
          ? (json['status'] as num).toInt()
          : int.tryParse(json['status']?.toString() ?? ''),
      message: json['message'] as String?,
      errors: errorMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'status': status,
        'message': message,
        'errors': errors,
      };
}
