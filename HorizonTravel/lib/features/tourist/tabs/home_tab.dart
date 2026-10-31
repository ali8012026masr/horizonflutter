import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/service_slot.dart';
import '../../../data/models/tourist.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';
import '../../groups/groups_screen.dart';
import '../screens/ai_concierge_screen.dart';
import '../screens/slot_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;
  final Function(String category)? onSelectCategory;

  const HomeTab({
    super.key,
    this.onNavigateTab,
    this.onSelectCategory,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  Tourist? _tourist;
  List<ServiceSlot> _popularSlots = [];

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

    final userId = SessionManager.instance.userId;

    try {
      final futures = <Future<dynamic>>[
        _apiService.getActiveSlots().catchError((_) => <ServiceSlot>[]),
      ];

      if (userId != null && userId > 0) {
        futures.add(_apiService.getTouristProfile(userId).catchError((_) => Tourist(id: userId)));
      }

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          _popularSlots = (results[0] as List<ServiceSlot>).take(10).toList();
          if (results.length > 1) {
            _tourist = results[1] as Tourist;
          }
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
    final name = _tourist?.fullName ?? SessionManager.instance.fullName ?? 'Traveler';

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting & Points Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyPrimary, AppColors.navyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $name!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Where would you like to travel next?',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.accent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Loyalty Points: ${_tourist?.loyaltyPoints ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Action Cards
            const Text(
              'Explore Horizon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'AI Concierge',
                    subtitle: 'Smart trip planner',
                    icon: Icons.auto_awesome,
                    iconColor: AppColors.coralAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AiConciergeScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    title: 'Travel Groups',
                    subtitle: 'Travel with peers',
                    icon: Icons.groups_rounded,
                    iconColor: AppColors.tealSuccess,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GroupsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Find Guides',
                    subtitle: 'Local experts',
                    icon: Icons.person_pin_circle_rounded,
                    iconColor: AppColors.primary,
                    onTap: () => widget.onNavigateTab?.call(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    title: 'All Services',
                    subtitle: 'Hotels, rides & tours',
                    icon: Icons.explore_rounded,
                    iconColor: AppColors.accent,
                    onTap: () => widget.onNavigateTab?.call(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Categories
            const Text(
              'Browse Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('HOTEL', Icons.hotel, 'Hotels'),
                  _buildCategoryChip('RESORT', Icons.beach_access, 'Resorts'),
                  _buildCategoryChip('BUS', Icons.directions_bus, 'Buses'),
                  _buildCategoryChip('TRAIN', Icons.train, 'Trains'),
                  _buildCategoryChip('AIRPLANE', Icons.flight, 'Flights'),
                  _buildCategoryChip(ServiceCategory.amusementPark, Icons.attractions, 'Attractions'),
                  _buildCategoryChip('BUFFET', Icons.restaurant, 'Buffets'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Popular / Recommended Services
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateTab?.call(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null && _popularSlots.isEmpty)
              ErrorStateView(message: _errorMessage!, onRetry: _loadData)
            else if (_popularSlots.isEmpty)
              const EmptyStateView(
                icon: Icons.explore_off,
                title: 'No Services Available',
                message: 'Check back soon for upcoming travel services.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _popularSlots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final slot = _popularSlots[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (slot.id != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SlotDetailScreen(slotId: slot.id!),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StatusChip(
                                  label: Formatters.capitalizeWords(slot.category),
                                  status: 'CONFIRMED',
                                ),
                                Text(
                                  Formatters.formatCurrency(slot.price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slot.title ?? 'Service Slot #${slot.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (slot.description != null && slot.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                slot.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Cap: ${slot.capacity ?? 0}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${slot.durationMinutes ?? 0} mins',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withValues(alpha: 0.15),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String categoryKey, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: AppColors.primary),
        backgroundColor: Theme.of(context).cardColor,
        side: const BorderSide(color: AppColors.outlineVariant, width: 0.8),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        ),
        onPressed: () {
          widget.onSelectCategory?.call(categoryKey);
        },
      ),
    );
  }
}
