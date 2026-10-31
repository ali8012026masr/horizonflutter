import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../core/widgets/theme_selection_dialog.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';
import '../../../data/models/ratings.dart';
import '../../../theme/app_colors.dart';
import '../../auth/login_screen.dart';
import '../../shared/change_password_screen.dart';
import '../../shared/notifications_screen.dart';
import '../screens/edit_guide_profile_screen.dart';

class GuideProfileTab extends StatefulWidget {
  const GuideProfileTab({super.key});

  @override
  State<GuideProfileTab> createState() => _GuideProfileTabState();
}

class _GuideProfileTabState extends State<GuideProfileTab> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Guide? _guide;
  List<GuideRating> _ratings = [];

  @override
  void initState() {
    super.initState();
    _loadProfileAndRatings();
  }

  Future<void> _loadProfileAndRatings() async {
    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Guide session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getGuideById(guideId),
        _apiService.getGuideRatings(guideId).catchError((_) => <GuideRating>[]),
      ]);

      if (mounted) {
        setState(() {
          _guide = results[0] as Guide;
          _ratings = results[1] as List<GuideRating>;
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

  Future<void> _toggleAvailability(bool value) async {
    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0 || _guide == null) return;

    try {
      final req = UpdateGuideRequest(
        fullName: _guide!.fullName ?? '',
        phone: _guide!.phone,
        address: _guide!.address,
        location: _guide!.location,
        languages: _guide!.languages,
        experienceYears: _guide!.experienceYears,
        defaultPrice: _guide!.defaultPrice,
        negotiable: _guide!.negotiable,
        bio: _guide!.bio,
        available: value,
      );

      final updated = await _apiService.updateGuideProfile(guideId, req);
      if (mounted) {
        setState(() {
          _guide = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(value ? 'Status set to AVAILABLE' : 'Status set to OFFLINE')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
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
    if (_isLoading && _guide == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _guide == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadProfileAndRatings,
      );
    }

    final guide = _guide;

    return RefreshIndicator(
      onRefresh: _loadProfileAndRatings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          children: [
            // Profile Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        (guide?.fullName ?? 'G').isNotEmpty ? (guide?.fullName ?? 'G')[0].toUpperCase() : 'G',
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      guide?.fullName ?? 'Tour Guide',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide?.email ?? SessionManager.instance.email ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    if (guide?.location != null && guide!.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        guide.location!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                    const Divider(height: 24),

                    // Availability Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Available for Hire'),
                      subtitle: Text(
                        (guide?.available ?? false)
                            ? 'Tourists can see and request your services'
                            : 'Marked as busy/unavailable',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: guide?.available ?? false,
                      onChanged: _toggleAvailability,
                    ),
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
                    leading: const Icon(Icons.person_outline, color: AppColors.primary),
                    title: const Text('Edit Guide Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const EditGuideProfileScreen()),
                      );
                      if (updated == true) _loadProfileAndRatings();
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
            const SizedBox(height: 20),

            // Reviews Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tourist Reviews (${_ratings.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            if (_ratings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('No reviews received yet from tourists.'),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ratings.length,
                separatorBuilder: (_, _) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final r = _ratings[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StarRatingBar(rating: (r.score ?? 5).toDouble(), size: 14),
                          Text(
                            Formatters.formatDate(r.ratedDate),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.comment ?? 'No comment provided.',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
