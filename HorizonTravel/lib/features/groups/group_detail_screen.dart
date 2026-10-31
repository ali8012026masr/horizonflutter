import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/formatting/formatters.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/common_views.dart';
import '../../data/api/api_service.dart';
import '../../data/models/group.dart';
import '../../theme/app_colors.dart';
import 'group_chat_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  Group? _group;
  List<GroupMember> _members = [];

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getGroupById(widget.groupId),
        _apiService.getGroupMembers(widget.groupId).catchError((_) => <GroupMember>[]),
      ]);

      if (mounted) {
        setState(() {
          _group = results[0] as Group;
          _members = results[1] as List<GroupMember>;
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

  Future<void> _linkBookingDialog() async {
    final controller = TextEditingController();
    final bookingId = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Link a Booking'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Booking ID',
            hintText: 'e.g. 104',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final id = int.tryParse(controller.text.trim());
              if (id != null && id > 0) {
                Navigator.of(ctx).pop(id);
              }
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );

    if (bookingId == null) return;

    setState(() => _isLoading = true);
    try {
      final updated = await _apiService.linkBookingToGroup(
        widget.groupId,
        GroupBookingRequest(bookingId: bookingId),
      );
      if (mounted) {
        setState(() {
          _group = updated;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking successfully linked to group!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to link booking: $e')),
        );
      }
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        title: 'Leave Group',
        message: 'Are you sure you want to leave this travel group?',
        confirmText: 'Leave',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.leaveGroup(widget.groupId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the group.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_group?.groupName ?? 'Travel Group'),
      ),
      bottomNavigationBar: _group != null ? _buildBottomActions() : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _group == null) {
      return ErrorStateView(
        message: _errorMessage ?? 'Group not found',
        onRetry: _loadGroup,
      );
    }

    final group = _group!;

    return RefreshIndicator(
      onRefresh: _loadGroup,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.group, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.groupName ?? 'Travel Group',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_members.length} members',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Join Code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Join Code',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              group.joinCode ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            if (group.joinCode != null) {
                              Clipboard.setData(ClipboardData(text: group.joinCode!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Join code copied to clipboard!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Code'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Linked Booking
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Linked Booking',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              group.bookingId != null && group.bookingId! > 0
                                  ? 'Booking #${group.bookingId}'
                                  : 'None Linked',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (group.bookingId == null || group.bookingId! <= 0)
                          TextButton.icon(
                            onPressed: _linkBookingDialog,
                            icon: const Icon(Icons.link, size: 16),
                            label: const Text('Link Booking'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Members Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Group Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_members.length} members',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Members List
            if (_members.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('No members found in this group.'),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final m = _members[index];
                  final name = m.fullName ?? 'Member #${m.touristId ?? index + 1}';
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceVariant,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'M',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Joined ${Formatters.formatDate(m.joinedAt)}${m.phone != null ? ' • ${m.phone}' : ''}',
                        style: const TextStyle(fontSize: 12),
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

  Widget _buildBottomActions() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    if (_group != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GroupChatScreen(
                            groupId: _group!.id ?? widget.groupId,
                            groupName: _group!.groupName ?? 'Travel Group',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Open Chat'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _leaveGroup,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Leave', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
