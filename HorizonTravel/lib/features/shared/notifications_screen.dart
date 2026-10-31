import 'package:flutter/material.dart';
import '../../core/formatting/formatters.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/common_views.dart';
import '../../data/api/api_service.dart';
import '../../data/models/notification_model.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getNotifications(userId);
      if (mounted) {
        setState(() {
          _notifications = list;
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

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.id == null || notification.read) return;
    try {
      final updated = await _apiService.markNotificationAsRead(notification.id!);
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = updated;
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadNotifications,
      );
    }

    if (_notifications.isEmpty) {
      return const EmptyStateView(
        icon: Icons.notifications_none_rounded,
        title: 'No Notifications',
        message: 'You have no notifications at this time.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return ListTile(
            tileColor: item.read ? null : AppColors.primaryContainer.withValues(alpha: 0.3),
            leading: CircleAvatar(
              backgroundColor: item.read ? AppColors.surfaceVariant : AppColors.primary,
              foregroundColor: item.read ? AppColors.onSurfaceVariant : Colors.white,
              child: const Icon(Icons.notifications, size: 20),
            ),
            title: Text(
              item.message ?? '',
              style: TextStyle(
                fontWeight: item.read ? FontWeight.normal : FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              Formatters.formatDateTime(item.createdAt),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: item.read
                ? null
                : Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.coralAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
            onTap: () => _markAsRead(item),
          );
        },
      ),
    );
  }
}
