import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/service_slot.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';
import 'rate_service_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  BookingDetailScreen({
    super.key,
    Booking? booking,
    int? bookingId,
  }) : booking = booking ?? Booking(id: bookingId);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final ApiService _apiService = ApiService();
  late Booking _currentBooking;
  ServiceSlot? _slot;
  List<Payment> _payments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ServiceSlot? slot;
      if (_currentBooking.serviceSlotId != null) {
        try {
          slot = await _apiService.getSlotById(_currentBooking.serviceSlotId!);
        } catch (_) {}
      }

      List<Payment> payments = [];
      if (_currentBooking.id != null) {
        try {
          payments = await _apiService.getPaymentsForBooking(_currentBooking.id!);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _slot = slot;
          _payments = payments;
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

  Future<void> _cancelBooking() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking?',
      positiveText: 'Cancel Booking',
      isDestructive: true,
    );
    if (!confirmed) return;

    if (_currentBooking.id == null) return;

    setState(() => _isLoading = true);
    try {
      final updated = await _apiService.updateBookingStatus(
        _currentBooking.id!,
        StatusRequest(status: BookingStatus.cancelled),
      );
      if (mounted) {
        setState(() {
          _currentBooking = updated;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    }
  }

  Future<void> _payNow() async {
    if (_currentBooking.id == null) return;
    setState(() => _isLoading = true);
    try {
      final payReq = PaymentRequest(
        bookingId: _currentBooking.id!,
        amount: _currentBooking.totalAmount ?? 0.0,
        method: PaymentMethod.card,
      );
      await _apiService.createPayment(payReq);
      _loadDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking #${_currentBooking.id ?? ""}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadDetails,
      );
    }

    final isCancelled = _currentBooking.status?.toUpperCase() == BookingStatus.cancelled;
    final isCompleted = _currentBooking.status?.toUpperCase() == BookingStatus.completed;
    final isUnpaid = _currentBooking.paymentStatus?.toUpperCase() == PaymentStatus.unpaid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Overview Card
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
                      Text(
                        'Booking #${_currentBooking.id}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      StatusChip(status: _currentBooking.status ?? 'PENDING'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment Status:', style: TextStyle(color: AppColors.textSecondary)),
                      StatusChip(status: _currentBooking.paymentStatus ?? 'UNPAID'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:', style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                        Formatters.formatCurrency(_currentBooking.totalAmount ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Booked On:', style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                        Formatters.formatDateTime(_currentBooking.bookingDate),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Linked Service Slot Card
          if (_slot != null) ...[
            const Text('Service Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _slot!.providerBusinessName ?? 'Provider Service',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (_slot!.origin != null && _slot!.destination != null)
                      Text(
                        '${_slot!.origin} → ${_slot!.destination}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    if (_slot!.locationName != null && _slot!.locationName!.isNotEmpty)
                      Text(_slot!.locationName!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      'Departure: ${Formatters.formatDateTime(_slot!.startDateTime)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Arrival: ${Formatters.formatDateTime(_slot!.endDateTime)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Payments Section
          const Text('Payments & Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_payments.isEmpty)
            const Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No payment transactions recorded for this booking.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ..._payments.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.payment, color: AppColors.tealSecondary),
                    title: Text(Formatters.formatCurrency(p.amount ?? 0), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Method: ${p.method ?? "CARD"} • ${Formatters.formatDateTime(p.transactionDate)}'),
                    trailing: StatusChip(status: p.status ?? 'PENDING'),
                  ),
                )),
          const SizedBox(height: 24),

          // Action Buttons
          if (!isCancelled && !isCompleted) ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.statusError,
                side: const BorderSide(color: AppColors.statusError),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Booking'),
              onPressed: _cancelBooking,
            ),
            const SizedBox(height: 12),
          ],

          if (isUnpaid && !isCancelled) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.payment),
              label: const Text('Pay Now'),
              onPressed: _payNow,
            ),
            const SizedBox(height: 12),
          ],

          if (isCompleted && _slot?.providerId != null) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.star_outline),
              label: const Text('Rate This Service'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RateServiceScreen(
                      bookingId: _currentBooking.id!,
                      providerId: _slot!.providerId!,
                      providerName: _slot!.providerBusinessName ?? 'Provider',
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
