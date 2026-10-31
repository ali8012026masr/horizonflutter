import 'package:flutter/material.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/theme_selection_dialog.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/tourist.dart';
import '../../../theme/app_colors.dart';
import '../../auth/login_screen.dart';
import '../../groups/groups_screen.dart';
import '../../shared/change_password_screen.dart';
import '../../shared/notifications_screen.dart';
import '../screens/edit_tourist_profile_screen.dart';

class TouristProfileTab extends StatefulWidget {
  const TouristProfileTab({super.key});

  @override
  State<TouristProfileTab> createState() => _TouristProfileTabState();
}

class _TouristProfileTabState extends State<TouristProfileTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  Tourist? _tourist;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tourist = await _apiService.getTouristProfile(userId);
      if (mounted) {
        setState(() {
          _tourist = tourist;
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

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        title: 'Delete Account',
        message: 'Warning: This action will permanently remove your tourist account and cannot be undone. Are you sure?',
        confirmText: 'Delete Permanently',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.deleteTouristProfile(userId);
      await SessionManager.instance.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your account has been deleted.')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: _errorMessage != null && _tourist == null
          ? ErrorStateView(message: _errorMessage!, onRetry: _loadProfile)
          : _isLoading && _tourist == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
              child: Column(
                children: [
                  // Profile Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              (_tourist?.fullName ?? SessionManager.instance.fullName ?? 'T').isNotEmpty
                                  ? (_tourist?.fullName ?? SessionManager.instance.fullName ?? 'T')[0].toUpperCase()
                                  : 'T',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _tourist?.fullName ?? SessionManager.instance.fullName ?? 'Tourist',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tourist?.email ?? SessionManager.instance.email ?? '',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          if (_tourist?.phone != null && _tourist!.phone!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _tourist!.phone!,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                          const Divider(height: 24),

                          // Loyalty Points
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.amberStar.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.amberStar, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Loyalty Points: ${_tourist?.loyaltyPoints ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.navyPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions Section
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: AppColors.primary),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final updated = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => const EditTouristProfileScreen()),
                            );
                            if (updated == true) _loadProfile();
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.groups_outlined, color: AppColors.primary),
                          title: const Text('Travel Groups'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const GroupsScreen()),
                            );
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Danger Zone Card
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout, color: AppColors.error),
                          title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                          onTap: _logout,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                          title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
                          onTap: _deleteAccount,
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
}
