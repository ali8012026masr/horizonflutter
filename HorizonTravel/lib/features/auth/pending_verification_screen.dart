import 'package:flutter/material.dart';
import '../../core/routing/role_router.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/common_views.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/api/api_service.dart';
import '../../theme/app_colors.dart';
import '../../util/constants.dart';
import 'login_screen.dart';

class PendingVerificationScreen extends StatefulWidget {
  const PendingVerificationScreen({super.key});

  @override
  State<PendingVerificationScreen> createState() => _PendingVerificationScreenState();
}

class _PendingVerificationScreenState extends State<PendingVerificationScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _refreshStatus() async {
    final session = SessionManager.instance;
    final userId = session.userId;
    final role = session.role;

    if (userId == null || userId <= 0 || role == null) {
      _logout();
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? newStatus;
      String? newVerificationStatus;
      String? newRejectionReason;

      if (role.toUpperCase() == Role.tourGuide) {
        final guide = await _apiService.getGuideById(userId);
        newStatus = guide.status;
        newVerificationStatus = guide.verificationStatus;
        newRejectionReason = guide.rejectionReason;
      } else if (role.toUpperCase() == Role.serviceProvider) {
        final provider = await _apiService.getProviderById(userId);
        newStatus = provider.status;
        newVerificationStatus = provider.verificationStatus;
        newRejectionReason = provider.rejectionReason;
      } else if (role.toUpperCase() == Role.tourist) {
        final tourist = await _apiService.getTouristProfile(userId);
        newStatus = tourist.status;
      }

      await session.updateStatusAndVerification(
        status: newStatus,
        verificationStatus: newVerificationStatus,
        rejectionReason: newRejectionReason,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        final isActive = newStatus?.toUpperCase() == UserStatus.active;
        final isApproved = role.toUpperCase() == Role.tourist ||
            newVerificationStatus?.toUpperCase() == VerificationStatus.approved;

        if (isActive && isApproved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account verified! Welcome to Horizon Travel.')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => RoleRouter.shellFor(role)),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status refreshed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh status: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      positiveText: 'Log Out',
    );
    if (!confirmed) return;

    await SessionManager.instance.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance;
    final status = session.status ?? UserStatus.pendingVerification;
    final verificationStatus = session.verificationStatus ?? VerificationStatus.pending;
    final rejectionReason = session.rejectionReason;

    String title;
    String description;
    String badgeStatus;

    if (status.toUpperCase() == UserStatus.suspended) {
      title = 'Account Suspended';
      description = 'Your account has been suspended by an administrator. Please contact support for assistance.';
      badgeStatus = UserStatus.suspended;
    } else if (status.toUpperCase() == UserStatus.revoked) {
      title = 'Access Revoked';
      description = 'Your account access has been revoked.';
      badgeStatus = UserStatus.revoked;
    } else if (verificationStatus.toUpperCase() == VerificationStatus.rejected) {
      title = 'Application Rejected';
      final reason = rejectionReason != null && rejectionReason.isNotEmpty
          ? rejectionReason
          : 'Requirements were not met.';
      description = 'Your application was rejected by an administrator:\n\n"$reason"';
      badgeStatus = VerificationStatus.rejected;
    } else {
      title = 'Application Under Review';
      description = 'Your account is currently awaiting administrator verification. You will be able to access all features once your profile is approved.';
      badgeStatus = VerificationStatus.pending;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Status'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  badgeStatus == VerificationStatus.rejected || badgeStatus == UserStatus.revoked
                      ? Icons.cancel_outlined
                      : badgeStatus == UserStatus.suspended
                          ? Icons.block_outlined
                          : Icons.hourglass_top_rounded,
                  size: 72,
                  color: badgeStatus == VerificationStatus.rejected || badgeStatus == UserStatus.revoked
                      ? AppColors.statusError
                      : badgeStatus == UserStatus.suspended
                          ? AppColors.statusSuspended
                          : AppColors.statusPending,
                ),
                const SizedBox(height: 20),
                StatusChip(status: badgeStatus, fontSize: 13),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 36),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _refreshStatus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Status'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _logout,
                  child: const Text('Log Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
