import 'package:flutter/material.dart';
import '../../core/widgets/app_bar_actions.dart';
import 'tabs/guide_availability_tab.dart';
import 'tabs/guide_dashboard_tab.dart';
import 'tabs/guide_profile_tab.dart';
import 'tabs/guide_requests_tab.dart';

class GuideMainShell extends StatefulWidget {
  final int initialTab;

  const GuideMainShell({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<GuideMainShell> createState() => _GuideMainShellState();
}

class _GuideMainShellState extends State<GuideMainShell> {
  late int _currentIndex;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        actions: const [
          AppBarNotificationBell(),
          SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          GuideDashboardTab(onNavigateTab: _onTabTapped),
          const GuideAvailabilityTab(),
          const GuideRequestsTab(),
          const GuideProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'Availability',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Requests',
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
        return 'Guide Dashboard';
      case 1:
        return 'My Availability';
      case 2:
        return 'Hire Requests';
      case 3:
        return 'Guide Profile';
      default:
        return 'Tour Guide';
    }
  }
}
