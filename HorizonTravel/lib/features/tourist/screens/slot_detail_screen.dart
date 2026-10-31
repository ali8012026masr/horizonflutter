import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/cart_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/ratings.dart';
import '../../../data/models/service_slot.dart';
import '../../../theme/app_colors.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class SlotDetailScreen extends StatefulWidget {
  final int slotId;

  const SlotDetailScreen({super.key, required this.slotId});

  @override
  State<SlotDetailScreen> createState() => _SlotDetailScreenState();
}

class _SlotDetailScreenState extends State<SlotDetailScreen> {
  final ApiService _apiService = ApiService();
  ServiceSlot? _slot;
  List<ServiceRating> _ratings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSlotDetails();
  }

  Future<void> _loadSlotDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final slot = await _apiService.getSlotById(widget.slotId);
      List<ServiceRating> ratings = [];
      if (slot.providerId != null) {
        try {
          ratings = await _apiService.getRatingsForProvider(slot.providerId!);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _slot = slot;
          _ratings = ratings;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_slot?.providerBusinessName ?? 'Service Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _slot != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadSlotDetails,
      );
    }

    final slot = _slot!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(status: slot.category ?? 'SERVICE'),
                      if (slot.status != null) StatusChip(status: slot.status!),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slot.providerBusinessName ?? 'Service Slot',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  if (slot.providerRatingAvg != null && slot.providerRatingAvg! > 0)
                    StarRatingBar(
                      rating: slot.providerRatingAvg!,
                      count: slot.providerRatingCount,
                    ),
                  const Divider(height: 24),
                  if (slot.origin != null || slot.destination != null) ...[
                    _buildInfoRow(
                      Icons.navigation_outlined,
                      'Route',
                      '${slot.origin ?? "N/A"} → ${slot.destination ?? "N/A"}',
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (slot.locationName != null && slot.locationName!.isNotEmpty) ...[
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Location',
                      slot.locationName!,
                    ),
                    const SizedBox(height: 10),
                  ],
                  _buildInfoRow(
                    Icons.schedule_outlined,
                    'Departure / Start',
                    Formatters.formatDateTime(slot.startDateTime),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.event_available_outlined,
                    'Arrival / End',
                    Formatters.formatDateTime(slot.endDateTime),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.event_seat_outlined,
                    'Available Seats',
                    '${slot.availableSeats ?? 0} / ${slot.capacity ?? 0} seats',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Provider Reviews Section
          Text(
            'Provider Reviews (${_ratings.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_ratings.isEmpty)
            const Text(
              'No reviews yet for this provider.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ratings.length,
              separatorBuilder: (_, _) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final rating = _ratings[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StarRatingBar(rating: (rating.score ?? 5).toDouble(), size: 15),
                        Text(
                          Formatters.formatDate(rating.ratedDate),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        rating.comment!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                );
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.tealSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final slot = _slot!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price per seat', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  Formatters.formatCurrency(slot.price ?? 0),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                final added = await CartManager.instance.addItem(slot);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(added ? 'Added to cart' : 'Already in cart'),
                      action: SnackBarAction(
                        label: 'View Cart',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add to Cart'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(slots: [slot]),
                  ),
                );
              },
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
