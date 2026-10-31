import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';
import '../../../theme/app_colors.dart';
import '../screens/guide_detail_screen.dart';

class GuidesTab extends StatefulWidget {
  const GuidesTab({super.key});

  @override
  State<GuidesTab> createState() => _GuidesTabState();
}

class _GuidesTabState extends State<GuidesTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Guide> _allGuides = [];
  List<Guide> _filteredGuides = [];

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getActiveGuides();
      if (mounted) {
        setState(() {
          _allGuides = list;
          _isLoading = false;
        });
        _applySearch(_searchController.text);
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

  void _applySearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredGuides = List.from(_allGuides);
      } else {
        _filteredGuides = _allGuides.where((guide) {
          final name = (guide.fullName ?? '').toLowerCase();
          final loc = (guide.location ?? '').toLowerCase();
          final bio = (guide.bio ?? '').toLowerCase();
          final langs = (guide.languages ?? []).join(' ').toLowerCase();
          return name.contains(q) || loc.contains(q) || bio.contains(q) || langs.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search guides by name, location, language...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applySearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: _applySearch,
          ),
        ),

        // List Body
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allGuides.isEmpty) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadGuides,
      );
    }

    if (_filteredGuides.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadGuides,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.person_search_outlined,
              title: 'No Guides Found',
              message: 'No tour guides match your search criteria.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGuides,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _filteredGuides.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final guide = _filteredGuides[index];
          final isAvail = guide.available;

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GuideDetailScreen(guideId: guide.id ?? 0),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            (guide.fullName ?? 'G').isNotEmpty ? (guide.fullName ?? 'G')[0].toUpperCase() : 'G',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      guide.fullName ?? 'Tour Guide',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  StatusChip(
                                    label: isAvail ? 'AVAILABLE' : 'BUSY',
                                    status: isAvail ? 'AVAILABLE' : 'UNAVAILABLE',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      guide.location ?? 'Location not specified',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: AppColors.amberStar),
                            const SizedBox(width: 4),
                            Text(
                              (guide.ratingAvg ?? 0) > 0
                                  ? '${guide.ratingAvg!.toStringAsFixed(1)} (${guide.ratingCount ?? 0})'
                                  : 'New',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.work_outline, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${guide.experienceYears ?? 0} yrs exp',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          '${Formatters.formatCurrency(guide.defaultPrice)} / day',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
