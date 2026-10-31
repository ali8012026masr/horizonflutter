import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide_availability.dart';
import '../../../theme/app_colors.dart';
import '../screens/create_availability_screen.dart';
import '../screens/edit_availability_screen.dart';

class GuideAvailabilityTab extends StatefulWidget {
  const GuideAvailabilityTab({super.key});

  @override
  State<GuideAvailabilityTab> createState() => _GuideAvailabilityTabState();
}

class _GuideAvailabilityTabState extends State<GuideAvailabilityTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<GuideAvailability> _allSlots = [];
  List<GuideAvailability> _filteredSlots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Guide session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getGuideAvailability(guideId);
      if (mounted) {
        setState(() {
          _allSlots = list;
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
        _filteredSlots = List.from(_allSlots);
      } else {
        _filteredSlots = _allSlots.where((a) {
          final date = (a.date ?? '').toLowerCase();
          final loc = (a.location ?? '').toLowerCase();
          final notes = (a.notes ?? '').toLowerCase();
          final status = (a.status ?? '').toLowerCase();
          return date.contains(q) || loc.contains(q) || notes.contains(q) || status.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search availability by date or location...',
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

            // List Content
            Expanded(child: _buildList()),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final res = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const CreateAvailabilityScreen()),
              );
              if (res == true) _loadAvailability();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Slot'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allSlots.isEmpty) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadAvailability,
      );
    }

    if (_filteredSlots.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAvailability,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.event_busy,
              title: 'No Availability Slots',
              message: 'Add your available dates and time windows so tourists can hire you.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAvailability,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _filteredSlots.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final slot = _filteredSlots[index];
          final status = slot.status ?? 'OPEN';

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.event_available, color: AppColors.primary),
              ),
              title: Text(
                '${Formatters.formatDate(slot.date)} (${slot.startTime ?? ''} - ${slot.endTime ?? ''})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                '${slot.location != null && slot.location!.isNotEmpty ? "Location: ${slot.location}\n" : ""}${slot.notes ?? "No notes"}',
                style: const TextStyle(fontSize: 12),
              ),
              isThreeLine: slot.location != null && slot.location!.isNotEmpty,
              trailing: StatusChip(label: status, status: status),
              onTap: () async {
                if (slot.id != null) {
                  final res = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => EditAvailabilityScreen(availabilityId: slot.id!),
                    ),
                  );
                  if (res == true) _loadAvailability();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
