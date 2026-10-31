import 'package:flutter/material.dart';
import '../../core/widgets/app_bar_actions.dart';
import 'tabs/provider_dashboard_tab.dart';
import 'tabs/provider_ledger_tab.dart';
import 'tabs/provider_profile_tab.dart';
import 'tabs/provider_slots_tab.dart';

class ProviderMainShell extends StatefulWidget {
  final int initialTab;

  const ProviderMainShell({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<ProviderMainShell> createState() => _ProviderMainShellState();
}

class _ProviderMainShellState extends State<ProviderMainShell> {
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
          ProviderDashboardTab(onNavigateTab: _onTabTapped),
          const ProviderSlotsTab(),
          const ProviderLedgerTab(),
          const ProviderProfileTab(),
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
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Slots',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Ledger',
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
        return 'Provider Dashboard';
      case 1:
        return 'My Service Slots';
      case 2:
        return 'Financial Ledger';
      case 3:
        return 'Provider Profile';
      default:
        return 'Service Provider';
    }
  }
}
