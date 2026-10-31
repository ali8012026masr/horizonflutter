import 'package:flutter/material.dart';
import '../../features/admin/admin_main_shell.dart';
import '../../features/auth/pending_verification_screen.dart';
import '../../features/guide/guide_main_shell.dart';
import '../../features/provider/provider_main_shell.dart';
import '../../features/tourist/tourist_main_shell.dart';
import '../../util/constants.dart';

class RoleRouter {
  static Widget shellFor(String? role) {
    if (role == null) {
      return const TouristMainShell();
    }
    switch (role.toUpperCase()) {
      case Role.tourGuide:
        return const GuideMainShell();
      case Role.serviceProvider:
        return const ProviderMainShell();
      case Role.admin:
        return const AdminMainShell();
      case Role.tourist:
      default:
        return const TouristMainShell();
    }
  }

  static Widget routeForUser({
    required String? role,
    String? status,
    String? verificationStatus,
  }) {
    final r = role?.toUpperCase() ?? Role.tourist;
    final s = status?.toUpperCase() ?? UserStatus.active;
    final v = verificationStatus?.toUpperCase() ?? VerificationStatus.approved;

    if (s != UserStatus.active) {
      return const PendingVerificationScreen();
    }

    if (r == Role.tourGuide || r == Role.serviceProvider) {
      if (v != VerificationStatus.approved) {
        return const PendingVerificationScreen();
      }
    }

    return shellFor(r);
  }
}
