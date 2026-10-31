import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/admin_user.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminUser> _allUsers = [];
  List<AdminUser> _filteredUsers = [];

  String? _selectedRole;
  String? _selectedStatus;

  final List<String> _roles = ['ALL', Role.tourist, Role.tourGuide, Role.serviceProvider, Role.admin];
  final List<String> _statuses = ['ALL', UserStatus.active, UserStatus.pendingVerification, UserStatus.suspended, UserStatus.revoked];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getUsers(
        role: _selectedRole,
        status: _selectedStatus,
      );
      if (mounted) {
        setState(() {
          _allUsers = list;
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
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((u) {
          final email = (u.email ?? '').toLowerCase();
          final name = (u.fullName ?? '').toLowerCase();
          final role = (u.role ?? '').toLowerCase();
          return email.contains(q) || name.contains(q) || role.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _changeUserStatus(AdminUser user) async {
    String selected = user.status ?? UserStatus.active;
    final newStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Change Status: ${user.fullName ?? user.email}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserStatus.active,
              UserStatus.pendingVerification,
              UserStatus.suspended,
              UserStatus.revoked,
            ].map((st) {
              return RadioListTile<String>(
                title: Text(st),
                value: st,
                groupValue: selected,
                onChanged: (val) {
                  if (val != null) setDialogState(() => selected = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(selected),
              child: const Text('Save Status'),
            ),
          ],
        ),
      ),
    );

    if (newStatus == null || newStatus == user.status || user.id == null) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.updateUserStatus(user.id!, UpdateUserStatusRequest(status: newStatus));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User status updated to $newStatus')),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name, email, or role...',
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

        // Role Filter Chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _roles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final r = _roles[index];
              final isSelected = (r == 'ALL' && _selectedRole == null) || (r == _selectedRole);
              return ChoiceChip(
                showCheckmark: false,
                selectedColor: AppColors.primaryContainer,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: isSelected ? 1.2 : 0.8,
                ),
                label: Text(
                  r == 'ALL' ? 'All Roles' : Formatters.capitalizeWords(r),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedRole = (r == 'ALL' ? null : r));
                    _loadUsers();
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // List
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allUsers.isEmpty) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadUsers);
    }

    if (_filteredUsers.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadUsers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.people_outline,
              title: 'No Users Found',
              message: 'No user accounts match your filters.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _filteredUsers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final u = _filteredUsers[index];
          final status = u.status ?? UserStatus.active;
          final role = u.role ?? Role.tourist;

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  (u.fullName ?? u.email ?? 'U').isNotEmpty
                      ? (u.fullName ?? u.email ?? 'U')[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              title: Text(
                u.fullName ?? u.email ?? 'User #${u.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${u.email ?? ""}\nRole: ${Formatters.capitalizeWords(role)}',
                style: const TextStyle(fontSize: 12),
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusChip(label: status, status: status),
                  const SizedBox(height: 4),
                  const Text('Tap to edit', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
              onTap: () => _changeUserStatus(u),
            ),
          );
        },
      ),
    );
  }
}
