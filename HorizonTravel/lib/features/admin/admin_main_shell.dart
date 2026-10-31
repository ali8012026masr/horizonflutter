import 'package:flutter/material.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/app_bar_actions.dart';
import '../../core/widgets/common_views.dart';
import '../../core/widgets/theme_selection_dialog.dart';
import '../auth/login_screen.dart';
import '../shared/change_password_screen.dart';
import 'tabs/admin_finance_tab.dart';
import 'tabs/admin_reports_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_verifications_tab.dart';

class AdminMainShell extends StatefulWidget {
  final int initialTab;

  const AdminMainShell({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out of Admin Portal?',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        actions: [
          const AppBarNotificationBell(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'theme') {
                showDialog(context: context, builder: (_) => const ThemeSelectionDialog());
              } else if (val == 'password') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              } else if (val == 'logout') {
                _logout();
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'theme', child: Text('Theme Settings')),
              PopupMenuItem(value: 'password', child: Text('Change Password')),
              PopupMenuItem(value: 'logout', child: Text('Sign Out')),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          AdminVerificationsTab(),
          AdminUsersTab(),
          AdminFinanceTab(),
          AdminReportsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user),
            label: 'Verifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Partner Verifications';
      case 1:
        return 'User Management';
      case 2:
        return 'Finance & Commissions';
      case 3:
        return 'System Reports';
      default:
        return 'Admin Portal';
    }
  }
}
