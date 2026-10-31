import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/service_slot.dart';
import '../../../theme/app_colors.dart';
import '../screens/create_slot_screen.dart';
import '../screens/edit_slot_screen.dart';

class ProviderSlotsTab extends StatefulWidget {
  const ProviderSlotsTab({super.key});

  @override
  State<ProviderSlotsTab> createState() => _ProviderSlotsTabState();
}

class _ProviderSlotsTabState extends State<ProviderSlotsTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<ServiceSlot> _allSlots = [];
  List<ServiceSlot> _filteredSlots = [];
  String _selectedStatus = 'ALL';

  final List<String> _statuses = ['ALL', 'OPEN', 'BOOKED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    final providerId = SessionManager.instance.userId;
    if (providerId == null || providerId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Provider session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getSlotsForProvider(providerId);
      if (mounted) {
        setState(() {
          _allSlots = list;
          _isLoading = false;
        });
        _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSlots = _allSlots.where((slot) {
        if (_selectedStatus != 'ALL') {
          if ((slot.status ?? '').toUpperCase() != _selectedStatus.toUpperCase()) {
            return false;
          }
        }

        if (query.isNotEmpty) {
          final title = (slot.title ?? '').toLowerCase();
          final cat = (slot.category ?? '').toLowerCase();
          final loc = (slot.location ?? '').toLowerCase();
          return title.contains(query) || cat.contains(query) || loc.contains(query);
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Search & Status Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search slots by title or location...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onChanged: (_) => _applyFilters(),
              ),
            ),

            // Status Filter Chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _statuses.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final st = _statuses[index];
                  final isSelected = _selectedStatus.toUpperCase() == st.toUpperCase();
                  return ChoiceChip(
                    showCheckmark: false,
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: Theme.of(context).cardColor,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                      width: isSelected ? 1.2 : 0.8,
                    ),
                    label: Text(
                      st == 'ALL' ? 'All Slots' : st,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedStatus = st);
                        _applyFilters();
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Slots List
            Expanded(child: _buildList()),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final res = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const CreateSlotScreen()),
              );
              if (res == true) _loadSlots();
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
        onRetry: _loadSlots,
      );
    }

    if (_filteredSlots.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSlots,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'No Slots Found',
              message: 'You have not added any service slots matching these filters.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSlots,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _filteredSlots.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final slot = _filteredSlots[index];
          final status = slot.status ?? 'OPEN';

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                if (slot.id != null) {
                  final res = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => EditSlotScreen(slotId: slot.id!),
                    ),
                  );
                  if (res == true) _loadSlots();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusChip(
                          label: Formatters.capitalizeWords(slot.category),
                          status: 'CONFIRMED',
                        ),
                        StatusChip(label: status, status: status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slot.title ?? 'Service Slot #${slot.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (slot.description != null && slot.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        slot.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.formatCurrency(slot.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('Cap: ${slot.capacity ?? 0}', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${slot.durationMinutes ?? 0}m', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
