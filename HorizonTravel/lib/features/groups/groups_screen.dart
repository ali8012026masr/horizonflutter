import 'package:flutter/material.dart';
import '../../core/formatting/formatters.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/common_views.dart';
import '../../data/api/api_service.dart';
import '../../data/models/group.dart';
import '../../theme/app_colors.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'join_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Group> _allGroups = [];
  List<Group> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getTouristGroups(userId);
      if (mounted) {
        setState(() {
          _allGroups = list;
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
    if (query.trim().isEmpty) {
      setState(() => _filteredGroups = List.from(_allGroups));
    } else {
      final q = query.trim().toLowerCase();
      setState(() {
        _filteredGroups = _allGroups.where((g) {
          final name = (g.groupName ?? '').toLowerCase();
          final code = (g.joinCode ?? '').toLowerCase();
          return name.contains(q) || code.contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGroups,
          ),
        ],
      ),
      body: Column(
        children: [
          // Action Buttons Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                      );
                      _loadGroups();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Group'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                      );
                      _loadGroups();
                    },
                    icon: const Icon(Icons.group_add, size: 18),
                    label: const Text('Join Group'),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search groups by name or code...',
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _applySearch,
            ),
          ),

          // Content List
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allGroups.isEmpty) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadGroups,
      );
    }

    if (_filteredGroups.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadGroups,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.groups_outlined,
              title: 'No Travel Groups',
              message: 'You have not joined or created any groups yet. Create one or join with a code!',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        itemCount: _filteredGroups.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final group = _filteredGroups[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.group, color: AppColors.primary),
              ),
              title: Text(
                group.groupName ?? 'Travel Group',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Code: ${group.joinCode ?? "N/A"} • Created: ${Formatters.formatDate(group.createdAt)}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                if (group.id != null) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(groupId: group.id!),
                    ),
                  );
                  _loadGroups();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
