import 'package:flutter/material.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/theme_selection_dialog.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/provider.dart';
import '../../../theme/app_colors.dart';
import '../../auth/login_screen.dart';
import '../../shared/change_password_screen.dart';
import '../../shared/notifications_screen.dart';
import '../screens/edit_provider_profile_screen.dart';

class ProviderProfileTab extends StatefulWidget {
  const ProviderProfileTab({super.key});

  @override
  State<ProviderProfileTab> createState() => _ProviderProfileTabState();
}

class _ProviderProfileTabState extends State<ProviderProfileTab> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Provider? _provider;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final providerId = SessionManager.instance.userId;
    if (providerId == null || providerId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Provider session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final p = await _apiService.getProviderById(providerId);
      if (mounted) {
        setState(() {
          _provider = p;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out of Horizon Travel?',
        confirmText: 'Sign Out',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

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
    if (_isLoading && _provider == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _provider == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadProfile,
      );
    }

    final p = _provider;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          children: [
            // Business Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryContainer,
                      child: const Icon(Icons.business_center, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p?.businessName ?? 'Business Agency',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p?.email ?? SessionManager.instance.email ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    StatusChip(
                      label: p?.verificationStatus ?? 'APPROVED',
                      status: p?.verificationStatus ?? 'APPROVED',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Contact Person', p?.fullName ?? 'N/A'),
                    const SizedBox(height: 6),
                    _buildInfoRow('Trade License', p?.tradeLicense ?? 'N/A'),
                    const SizedBox(height: 6),
                    _buildInfoRow('Category', p?.category ?? 'General'),
                    const SizedBox(height: 6),
                    _buildInfoRow('Phone', p?.phone ?? 'N/A'),
                    if (p?.address != null && p!.address!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildInfoRow('Address', p.address!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions Card
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    title: const Text('Edit Provider Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const EditProviderProfileScreen()),
                      );
                      if (updated == true) _loadProfile();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                    title: const Text('Theme Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ThemeSelectionDialog(),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
