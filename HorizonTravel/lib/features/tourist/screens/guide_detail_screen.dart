import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';
import '../../../data/models/guide_availability.dart';
import '../../../data/models/ratings.dart';
import '../../../theme/app_colors.dart';
import 'request_guide_screen.dart';

class GuideDetailScreen extends StatefulWidget {
  final int guideId;

  const GuideDetailScreen({
    super.key,
    required this.guideId,
  });

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  Guide? _guide;
  List<GuideAvailability> _availabilities = [];
  List<GuideRating> _ratings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getGuideById(widget.guideId),
        _apiService.getGuideAvailability(widget.guideId).catchError((_) => <GuideAvailability>[]),
        _apiService.getGuideRatings(widget.guideId).catchError((_) => <GuideRating>[]),
      ]);

      if (mounted) {
        setState(() {
          _guide = results[0] as Guide;
          _availabilities = results[1] as List<GuideAvailability>;
          _ratings = results[2] as List<GuideRating>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_guide?.fullName ?? 'Tour Guide Details'),
      ),
      bottomNavigationBar: _guide != null ? _buildBottomBar() : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _guide == null) {
      return ErrorStateView(
        message: _errorMessage ?? 'Failed to load tour guide details',
        onRetry: _loadData,
      );
    }

    final guide = _guide!;
    final isAvailable = guide.available;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            (guide.fullName ?? 'G').isNotEmpty
                                ? (guide.fullName ?? 'G')[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guide.fullName ?? 'Tour Guide',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      guide.location ?? 'Location not specified',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  StatusChip(
                                    label: isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                                    status: isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                                  ),
                                  if (guide.negotiable) ...[
                                    const SizedBox(width: 8),
                                    const StatusChip(
                                      label: 'Negotiable',
                                      status: 'CONFIRMED',
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          label: 'Experience',
                          value: '${guide.experienceYears ?? 0} yrs',
                          icon: Icons.work_outline,
                        ),
                        _buildStatItem(
                          label: 'Rating',
                          value: (guide.ratingAvg ?? 0) > 0
                              ? '${guide.ratingAvg!.toStringAsFixed(1)} ★'
                              : 'New',
                          icon: Icons.star_border,
                        ),
                        _buildStatItem(
                          label: 'Rate / Day',
                          value: Formatters.formatCurrency(guide.defaultPrice),
                          icon: Icons.payments_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            const Text(
              'About Guide',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.bio ?? 'No biography provided.',
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    if (guide.languages != null && guide.languages!.isNotEmpty) ...[
                      const Text(
                        'Languages Spoken:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: guide.languages!
                            .map((lang) => Chip(
                                  label: Text(lang, style: const TextStyle(fontSize: 12)),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Availability
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Availability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_availabilities.length} available',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_availabilities.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No specific availability slots listed. You may still send a booking request.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availabilities.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final a = _availabilities[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.event, color: AppColors.primary, size: 20),
                      ),
                      title: Text(
                        '${Formatters.formatDate(a.date)} (${a.startTime ?? ''} - ${a.endTime ?? ''})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Status: ${a.status ?? 'OPEN'}${a.location != null ? ' • ${a.location}' : ''}${a.notes != null ? '\n${a.notes}' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      isThreeLine: a.notes != null && a.notes!.isNotEmpty,
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Reviews & Ratings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tourist Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_ratings.length} reviews',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_ratings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No reviews yet for this guide.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
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

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () {
              if (_guide != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RequestGuideScreen(
                      guideId: _guide!.id,
                      guideName: _guide!.fullName ?? 'Tour Guide',
                      defaultPrice: _guide!.defaultPrice ?? 0.0,
                      negotiable: _guide!.negotiable,
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Hire / Request Guide', style: TextStyle(fontSize: 16)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
