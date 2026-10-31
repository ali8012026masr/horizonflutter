import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/api/api_service.dart';
import '../../features/shared/notifications_screen.dart';
import '../../features/tourist/screens/cart_screen.dart';
import '../../theme/app_colors.dart';
import '../storage/cart_manager.dart';
import '../storage/session_manager.dart';

class AppBarNotificationBell extends StatefulWidget {
  const AppBarNotificationBell({super.key});

  @override
  State<AppBarNotificationBell> createState() => _AppBarNotificationBellState();
}

class _AppBarNotificationBellState extends State<AppBarNotificationBell> {
  int _unreadCount = 0;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) return;
    try {
      final res = await _apiService.getUnreadNotificationCount(userId);
      if (mounted) {
        setState(() {
          _unreadCount = res.count;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        _fetchUnreadCount();
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (_unreadCount > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.coralAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  _unreadCount > 99 ? '99+' : '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppBarCartIcon extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBarCartIcon({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, cart, _) {
        final count = cart.count;
        return IconButton(
          tooltip: 'Cart',
          onPressed: onPressed ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined),
              if (count > 0)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.coralAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
