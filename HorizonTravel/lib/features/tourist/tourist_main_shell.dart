import 'package:flutter/material.dart';
import '../../core/widgets/app_bar_actions.dart';
import '../../theme/app_colors.dart';
import 'screens/ai_concierge_screen.dart';
import 'screens/cart_screen.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/explore_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/tourist_profile_tab.dart';

class TouristMainShell extends StatefulWidget {
  final int initialTab;
  final String? initialCategory;

  const TouristMainShell({
    super.key,
    int? initialTabIndex,
    int initialTab = 0,
    this.initialCategory,
  }) : initialTab = initialTabIndex ?? initialTab;

  @override
  State<TouristMainShell> createState() => _TouristMainShellState();
}

class _TouristMainShellState extends State<TouristMainShell> {
  late int _currentIndex;
  final GlobalKey<ExploreTabState> _exploreKey = GlobalKey<ExploreTabState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToExploreCategory(String category) {
    setState(() {
      _currentIndex = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _exploreKey.currentState?.filterCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, size: 24),
                  SizedBox(width: 8),
                  Text('Horizon Travel'),
                ],
              )
            : Text(_getTitleForIndex(_currentIndex)),
        actions: [
          const AppBarNotificationBell(),
          AppBarCartIcon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            onNavigateTab: _onTabTapped,
            onSelectCategory: _navigateToExploreCategory,
          ),
          ExploreTab(
            key: _exploreKey,
            initialCategory: widget.initialCategory,
          ),
          const BookingsTab(),
          const TouristProfileTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiConciergeScreen()),
          );
        },
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        tooltip: 'AI Concierge',
        child: const Icon(Icons.auto_awesome),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Horizon Travel';
      case 1:
        return 'Explore & Guides';
      case 2:
        return 'My Bookings';
      case 3:
        return 'My Profile';
      default:
        return 'Horizon Travel';
    }
  }
}
