import 'package:flutter/material.dart';
import '../../core/formatting/formatters.dart';
import '../../core/routing/role_router.dart';
import '../../core/storage/cart_manager.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/app_bar_actions.dart';
import '../../core/widgets/common_views.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/theme_selection_dialog.dart';
import '../../data/api/api_service.dart';
import '../../data/models/service_slot.dart';
import '../../theme/app_colors.dart';
import '../../util/constants.dart';
import '../auth/login_screen.dart';
import '../auth/register_chooser_screen.dart';
import '../shared/contact_us_screen.dart';
import '../tourist/screens/cart_screen.dart';
import '../tourist/screens/slot_detail_screen.dart';

class MainGuestScreen extends StatefulWidget {
  const MainGuestScreen({super.key});

  @override
  State<MainGuestScreen> createState() => _MainGuestScreenState();
}

class _MainGuestScreenState extends State<MainGuestScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<ServiceSlot> _allSlots = [];
  List<ServiceSlot> _filteredSlots = [];

  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'HOTEL',
    'RESORT',
    'BUS',
    'MICROBUS',
    'LAUNCH',
    'SHIP',
    'TRAIN',
    'AIRPLANE',
    ServiceCategory.amusementPark,
    'BUFFET',
    'TOUR_PACKAGE',
  ];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getActiveSlots();
      if (mounted) {
        setState(() {
          _allSlots = list;
          _isLoading = false;
        });
        _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSlots = _allSlots.where((slot) {
        if (_selectedCategory != 'ALL') {
          if ((slot.category ?? '').toUpperCase() != _selectedCategory.toUpperCase()) {
            return false;
          }
        }
        if (query.isNotEmpty) {
          final title = (slot.title ?? '').toLowerCase();
          final desc = (slot.description ?? '').toLowerCase();
          final cat = (slot.category ?? '').toLowerCase();
          return title.contains(query) || desc.contains(query) || cat.contains(query);
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = SessionManager.instance.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.explore,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horizon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Travel',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Theme',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              showDialog(context: context, builder: (_) => const ThemeSelectionDialog());
            },
          ),
          AppBarCartIcon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          if (!isLoggedIn) ...[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Sign In'),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterChooserScreen()),
                  );
                },
                child: const Text('Register'),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                onPressed: () {
                  final shell = RoleRouter.routeForUser(
                    role: SessionManager.instance.role,
                    status: SessionManager.instance.status,
                    verificationStatus: SessionManager.instance.verificationStatus,
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => shell),
                  );
                },
                child: const Text('My Portal'),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSlots,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Card
                    _buildHeroCard(),

                    // 2. Services Provided Section
                    _buildServicesSection(),

                    // 3. How It Works Section
                    _buildHowItWorksSection(),

                    // 4. Platform Facilities Section
                    _buildFacilitiesSection(),

                    // 5. Contact & Support Banner Card
                    _buildContactBanner(),

                    // 6. Search Provider Services Section Header
                    _buildSearchHeader(),

                    // 7. Search Input Field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search destination, city, or service name…',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applyFilters();
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                    ),

                    // 8. Categories Horizontal Bar
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory.toUpperCase() == cat.toUpperCase();
                          return ChoiceChip(
                            showCheckmark: false,
                            selectedColor: AppColors.primaryContainer,
                            backgroundColor: Theme.of(context).cardColor,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                              width: isSelected ? 1.2 : 0.8,
                            ),
                            label: Text(
                              cat == 'ALL' ? 'All' : Formatters.capitalizeWords(cat),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = cat);
                                _applyFilters();
                              }
                            },
                          );
                        },
                      ),
                    ),

                    // 9. Results Count
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '${_filteredSlots.length} services available',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),

                    // 10. Slots List View
                    _buildSlotsContainer(),

                    // 11. Bottom CTA Card
                    _buildBottomCtaCard(isLoggedIn),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Fixed Guest Bar
          if (!isLoggedIn)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Plan your next trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Sign up to book slots & hire guides', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterChooserScreen()),
                          );
                        },
                        child: const Text('Get Started'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discover Amazing places with Horizon Travel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your all-in-one smart travel ecosystem. Book transport, hotels, certified guides, and explore curated travel experiences.',
              style: TextStyle(
                color: AppColors.primaryContainer,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '✓ Verified\nProviders',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.navyLight.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '✓ Certified\nGuides',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '✓ 24/7 AI\nConcierge',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services Provided by Horizon',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          const Text(
            'Everything you need for seamless travel in one connected platform',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            icon: Icons.directions_bus_outlined,
            iconColor: AppColors.secondary,
            title: 'Intercity & Local Transport',
            desc: 'Reserve AC buses, launches, domestic flights, microbuses, and trains with real-time seat availability.',
          ),
          const SizedBox(height: 8),
          _buildServiceCard(
            icon: Icons.hotel_outlined,
            iconColor: AppColors.primary,
            title: 'Hotels & Eco-Resorts',
            desc: 'Find and book verified seaside resorts, luxury suites, and budget stays across top destinations.',
          ),
          const SizedBox(height: 8),
          _buildServiceCard(
            icon: Icons.person_pin_circle_outlined,
            iconColor: AppColors.warning,
            title: 'Certified Local Tour Guides',
            desc: 'Hire licensed guides with transparent ratings, negotiable pricing, and live GPS location tracking.',
          ),
          const SizedBox(height: 8),
          _buildServiceCard(
            icon: Icons.groups_outlined,
            iconColor: AppColors.primary,
            title: 'Group Tours & Community',
            desc: 'Join shared trips with other travelers or create your own group to share transport and tour costs.',
          ),
          const SizedBox(height: 8),
          _buildServiceCard(
            icon: Icons.auto_awesome,
            iconColor: AppColors.secondary,
            title: 'AI Smart Travel Concierge',
            desc: 'Get personalized itineraries, budget advice, and instant travel support powered by AI.',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How Horizon Travel Works',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          const Text(
            'Three easy steps to your next adventure',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _HowStepRow(
                    icon: Icons.search,
                    iconColor: AppColors.secondary,
                    title: '1. Search & Compare',
                    desc: 'Browse real-time service slots, verify pricing, and check provider reviews without logging in.',
                  ),
                  Divider(height: 24, color: AppColors.outlineVariant),
                  _HowStepRow(
                    icon: Icons.lock_open_outlined,
                    iconColor: AppColors.primary,
                    title: '2. Sign In & Book',
                    desc: 'Create an account or sign in to reserve seats, book hotel rooms, or hire certified guides securely.',
                  ),
                  Divider(height: 24, color: AppColors.outlineVariant),
                  _HowStepRow(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    title: '3. Travel with Confidence',
                    desc: 'Receive instant booking confirmations, live guide location tracking, and 24/7 assistance.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Facilities & Guarantees',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          const Text(
            'Built with safety, transparency, and high performance in mind',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _HowStepRow(
                    icon: Icons.verified_user_outlined,
                    iconColor: AppColors.primary,
                    title: '100% Admin-Verified Providers',
                    desc: 'Every tour guide and service provider undergoes manual document and background verification before offering services.',
                  ),
                  Divider(height: 24, color: AppColors.outlineVariant),
                  _HowStepRow(
                    icon: Icons.location_searching_outlined,
                    iconColor: AppColors.secondary,
                    title: 'Live GPS Guide Tracking',
                    desc: 'Guides broadcast real-time locations during tours, providing enhanced tourist safety and easy group rendezvous.',
                  ),
                  Divider(height: 24, color: AppColors.outlineVariant),
                  _HowStepRow(
                    icon: Icons.chat_bubble_outline,
                    iconColor: AppColors.warning,
                    title: 'Dynamic Community & Chat',
                    desc: 'Connect with fellow tourists, form custom travel groups, split itinerary costs, and communicate via live group messaging.',
                  ),
                  Divider(height: 24, color: AppColors.outlineVariant),
                  _HowStepRow(
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.success,
                    title: 'Digital Vouchers & Cart System',
                    desc: 'Multi-service booking in one unified cart, instantly generating verifiable digital receipts and booking vouchers.',
                  ),
                  Divider(height: 24, color: AppColors.outlineVariant),
                  _HowStepRow(
                    icon: Icons.auto_awesome,
                    iconColor: AppColors.secondary,
                    title: '24/7 AI Smart Concierge',
                    desc: 'Instant intelligent responses for trip planning, destination recommendations, and budget calculation powered by AI.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_outlined, color: AppColors.secondary, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Need Assistance or Have Questions?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Our demo support team and emergency helplines are available 24/7. Reach out via call, email, or send us a message.',
              style: TextStyle(fontSize: 12, color: AppColors.onSecondaryContainer),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
              icon: const Icon(Icons.phone, size: 16),
              label: const Text('Contact Support & Info', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Provider Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          SizedBox(height: 2),
          Text(
            'Real-time availability from registered service providers',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            'Browse live services below. Sign in with an account to book.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsContainer() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _allSlots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ErrorStateView(
          message: _errorMessage!,
          onRetry: _loadSlots,
        ),
      );
    }

    if (_filteredSlots.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const EmptyStateView(
          icon: Icons.travel_explore_outlined,
          title: 'No Services Available',
          message: 'Check back soon for upcoming travel packages and slots.',
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredSlots.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slot = _filteredSlots[index];
        final inCart = CartManager.instance.isInCart(slot.id ?? -1);

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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Cap: ${slot.capacity ?? 0}', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${slot.durationMinutes ?? 0}m', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                          color: inCart ? AppColors.accent : AppColors.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          if (slot.id != null) {
                            if (inCart) {
                              CartManager.instance.removeItem(slot.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Removed from cart')),
                              );
                            } else {
                              CartManager.instance.addItem(slot);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart!')),
                              );
                            }
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomCtaCard(bool isLoggedIn) {
    if (isLoggedIn) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Ready to Begin Your Journey?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sign in or create a free account to book service slots, connect with local guides, and unlock full access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Sign In to Your Account'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                    );
                  },
                  child: const Text('Contact Support'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterChooserScreen()),
                    );
                  },
                  child: const Text('Create Free Account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HowStepRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;

  const _HowStepRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
