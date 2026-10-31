import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/cart_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/service_slot.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';
import '../screens/slot_detail_screen.dart';

class SlotsTab extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;

  const SlotsTab({
    super.key,
    this.initialCategory,
    this.initialQuery,
  });

  @override
  State<SlotsTab> createState() => SlotsTabState();
}

class SlotsTabState extends State<SlotsTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<ServiceSlot> _allSlots = [];
  List<ServiceSlot> _filteredSlots = [];

  String _selectedCategory = 'ALL';
  double? _maxPrice;

  final List<String> _categories = [
    'ALL',
    'HOTEL',
    'RESORT',
    'BUS',
    'TRAIN',
    'AIRPLANE',
    ServiceCategory.amusementPark,
    'BUFFET',
    'TOUR_PACKAGE',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    loadSlots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setFilterCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  Future<void> loadSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getActiveSlots();
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
        // Category filter
        if (_selectedCategory != 'ALL') {
          if ((slot.category ?? '').toUpperCase() != _selectedCategory.toUpperCase()) {
            return false;
          }
        }

        // Max price filter
        if (_maxPrice != null && (slot.price ?? 0.0) > _maxPrice!) {
          return false;
        }

        // Search query filter
        if (query.isNotEmpty) {
          final title = (slot.title ?? '').toLowerCase();
          final desc = (slot.description ?? '').toLowerCase();
          final cat = (slot.category ?? '').toLowerCase();
          return title.contains(query) || desc.contains(query) || cat.contains(query);
        }

        return true;
      }).toList();
    });
  }

  void _showPriceFilterDialog() {
    final controller = TextEditingController(text: _maxPrice != null ? _maxPrice!.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter by Max Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Max Price (৳)',
            hintText: 'e.g. 5000',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _maxPrice = null);
              _applyFilters();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              setState(() => _maxPrice = val);
              _applyFilters();
              Navigator.of(ctx).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filter Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search destinations, hotels...',
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
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: Badge(
                  isLabelVisible: _maxPrice != null,
                  child: const Icon(Icons.tune),
                ),
                onPressed: _showPriceFilterDialog,
                tooltip: 'Price Filter',
              ),
            ],
          ),
        ),

        // Category Filter Chips Bar
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory.toUpperCase() == cat.toUpperCase();
              return ChoiceChip(
                showCheckmark: false,
                selectedColor: AppColors.primaryContainer,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: isSelected ? 1.2 : 0.8,
                ),
                label: Text(
                  cat == 'ALL' ? 'All Services' : Formatters.capitalizeWords(cat),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat);
                    _applyFilters();
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // List Body
        Expanded(child: _buildList()),
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
        onRetry: loadSlots,
      );
    }

    if (_filteredSlots.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadSlots,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: EmptyStateView(
              icon: Icons.search_off,
              title: 'No Matching Services',
              message: _allSlots.isEmpty
                  ? 'No services currently available.'
                  : 'Try adjusting your search query or filters.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadSlots,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _filteredSlots.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final slot = _filteredSlots[index];
          final inCart = CartManager.instance.isInCart(slot.id ?? -1);

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (slot.id != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SlotDetailScreen(slotId: slot.id!),
                    ),
                  );
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
                        Text(
                          Formatters.formatCurrency(slot.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slot.title ?? 'Service Slot #${slot.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Capacity: ${slot.capacity ?? 0}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${slot.durationMinutes ?? 0}m',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                            color: inCart ? AppColors.accent : AppColors.primary,
                            size: 20,
                          ),
                          tooltip: inCart ? 'In Cart' : 'Add to Cart',
                          onPressed: () {
                            if (slot.id != null) {
                              if (inCart) {
                                CartManager.instance.removeItem(slot.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Removed from cart')),
                                );
                              } else {
                                CartManager.instance.addItem(slot);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to cart!')),
                                );
                              }
                              setState(() {});
                            }
                          },
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
