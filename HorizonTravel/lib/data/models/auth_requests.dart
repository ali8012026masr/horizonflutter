export 'tourist.dart' show RegisterTouristRequest, UpdateTouristRequest;
export 'guide.dart' show RegisterGuideRequest, UpdateGuideRequest;
export 'provider.dart' show RegisterProviderRequest, UpdateProviderRequest;
export 'admin_user.dart' show VerifyRequest;

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'newPassword': newPassword,
      };
}
