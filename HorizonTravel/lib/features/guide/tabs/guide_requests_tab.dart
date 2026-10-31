import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide_booking.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';

class GuideRequestsTab extends StatefulWidget {
  const GuideRequestsTab({super.key});

  @override
  State<GuideRequestsTab> createState() => _GuideRequestsTabState();
}

class _GuideRequestsTabState extends State<GuideRequestsTab> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<GuideBooking> _allBookings = [];
  List<GuideBooking> _filteredBookings = [];
  String _selectedStatus = 'ALL';

  final List<String> _filters = [
    'ALL',
    GuideBookingStatus.requested,
    GuideBookingStatus.accepted,
    GuideBookingStatus.completed,
    GuideBookingStatus.declined,
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
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
      final list = await _apiService.getGuideBookings(guideId);
      if (mounted) {
        setState(() {
          _allBookings = list;
          _isLoading = false;
        });
        _applyFilter();
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

  void _applyFilter() {
    setState(() {
      if (_selectedStatus == 'ALL') {
        _filteredBookings = List.from(_allBookings);
      } else {
        _filteredBookings = _allBookings.where((b) {
          return (b.status ?? '').toUpperCase() == _selectedStatus.toUpperCase();
        }).toList();
      }
    });
  }

  Future<void> _updateStatus(int bookingId, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateGuideBookingStatus(
        bookingId,
        UpdateGuideBookingStatusRequest(status: newStatus),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hire request updated to $newStatus')),
        );
        _loadBookings();
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

  Future<void> _markCashPaymentReceived(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        title: 'Payment Received',
        message: 'Confirm that you have received direct cash payment from the tourist for this booking?',
        confirmText: 'Confirm Cash Received',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.markGuideBookingPaymentReceived(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment marked as received!')),
        );
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Filter Chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedStatus.toUpperCase() == filter.toUpperCase();
              return ChoiceChip(
                showCheckmark: false,
                selectedColor: AppColors.primaryContainer,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: isSelected ? 1.2 : 0.8,
                ),
                label: Text(
                  filter == 'ALL' ? 'All Requests' : Formatters.capitalizeWords(filter),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedStatus = filter);
                    _applyFilter();
                  }
                },
              );
            },
          ),
        ),

        // Content
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allBookings.isEmpty) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadBookings,
      );
    }

    if (_filteredBookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.assignment_outlined,
              title: 'No Booking Requests',
              message: 'No hire requests match the selected status filter.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _filteredBookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final b = _filteredBookings[index];
          final status = (b.status ?? GuideBookingStatus.requested).toUpperCase();
          final isRequested = status == GuideBookingStatus.requested;
          final isAccepted = status == GuideBookingStatus.accepted;
          final isPaid = b.paymentReceived;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hire Request #${b.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      StatusChip(label: status, status: status),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tourist #${b.touristId}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      Text(
                        'Date: ${Formatters.formatDate(b.scheduleDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.formatCurrency(b.agreedPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      StatusChip(
                        label: isPaid ? 'PAID' : 'PAYMENT PENDING',
                        status: isPaid ? 'CONFIRMED' : 'PENDING',
                      ),
                    ],
                  ),

                  // Action Buttons
                  if (isRequested) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _updateStatus(b.id ?? 0, GuideBookingStatus.accepted),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.tealSuccess),
                            child: const Text('Accept'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateStatus(b.id ?? 0, GuideBookingStatus.declined),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('Decline', style: TextStyle(color: AppColors.error)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (isAccepted) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _updateStatus(b.id ?? 0, GuideBookingStatus.completed),
                            child: const Text('Mark Completed'),
                          ),
                        ),
                        if (!isPaid) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _markCashPaymentReceived(b.id ?? 0),
                              child: const Text('Cash Received', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
