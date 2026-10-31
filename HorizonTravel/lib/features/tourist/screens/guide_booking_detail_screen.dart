import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';
import '../../../data/models/guide_booking.dart';
import '../../../data/models/payment.dart';
import '../../../features/reports/pdf_report_helper.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';
import 'guide_location_screen.dart';
import 'rate_guide_screen.dart';

class GuideBookingDetailScreen extends StatefulWidget {
  final int guideBookingId;

  const GuideBookingDetailScreen({
    super.key,
    required this.guideBookingId,
  });

  @override
  State<GuideBookingDetailScreen> createState() => _GuideBookingDetailScreenState();
}

class _GuideBookingDetailScreenState extends State<GuideBookingDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  GuideBooking? _booking;
  Guide? _guide;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tourist session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getTouristGuideBookings(userId);
      final booking = list.firstWhere(
        (b) => b.id == widget.guideBookingId,
        orElse: () => throw Exception('Guide booking #${widget.guideBookingId} not found'),
      );

      Guide? guide;
      if (booking.tourGuideId != null && booking.tourGuideId! > 0) {
        try {
          guide = await _apiService.getGuideById(booking.tourGuideId!);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _booking = booking;
          _guide = guide;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        title: 'Cancel Booking',
        message: 'Are you sure you want to cancel this tour guide booking request?',
        confirmText: 'Yes, Cancel',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.updateGuideBookingStatus(
        widget.guideBookingId,
        UpdateGuideBookingStatusRequest(status: GuideBookingStatus.declined),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guide booking cancelled successfully')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _payNow() async {
    if (_booking == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Pay Guide Fee',
        message: 'Confirm payment of ${Formatters.formatCurrency(_booking!.agreedPrice)} for this guide hire?',
        confirmText: 'Pay via Card',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.createPayment(PaymentRequest(
        bookingId: _booking!.id ?? widget.guideBookingId,
        amount: _booking!.agreedPrice ?? 0.0,
        paymentMethod: PaymentMethod.creditCard,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment processed successfully!')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _downloadInvoice() async {
    if (_booking == null) return;
    try {
      await PdfReportHelper.generateAndDownloadReport(
        title: 'Guide Hire Invoice / Receipt',
        subtitle: 'Booking ID: #${_booking!.id} • Guide: ${_guide?.fullName ?? "Tour Guide"}',
        headers: ['Item / Description', 'Date', 'Price'],
        rows: [
          [
            'Guide Service: ${_guide?.fullName ?? "Tour Guide"}',
            Formatters.formatDate(_booking!.scheduleDate),
            Formatters.formatCurrency(_booking!.agreedPrice),
          ]
        ],
        summaryText: 'Total Paid: ${Formatters.formatCurrency(_booking!.agreedPrice)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hire Details #${widget.guideBookingId}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _booking == null) {
      return ErrorStateView(
        message: _errorMessage ?? 'Booking not found',
        onRetry: _loadData,
      );
    }

    final booking = _booking!;
    final status = booking.status ?? GuideBookingStatus.requested;
    final isRequested = status.toUpperCase() == GuideBookingStatus.requested;
    final isAccepted = status.toUpperCase() == GuideBookingStatus.accepted;
    final isCompleted = status.toUpperCase() == GuideBookingStatus.completed;
    final canCancel = isRequested || isAccepted;
    final isPaid = booking.paymentReceived;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hire Request #${booking.id}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      StatusChip(label: status, status: status),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Scheduled Date', Formatters.formatDate(booking.scheduleDate)),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Rate Type',
                    booking.negotiated ? 'Negotiated Rate' : 'Standard Rate',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Payment Status',
                    isPaid ? 'PAID (Received)' : 'PENDING PAYMENT',
                    valueColor: isPaid ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Agreed Price',
                    Formatters.formatCurrency(booking.agreedPrice),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Guide Info Card
          if (_guide != null) ...[
            const Text(
              'Assigned Tour Guide',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            (_guide!.fullName ?? 'G').isNotEmpty ? (_guide!.fullName ?? 'G')[0].toUpperCase() : 'G',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _guide!.fullName ?? 'Tour Guide',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (_guide!.location != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _guide!.location!,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                              if ((_guide!.ratingAvg ?? 0) > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '★ ${_guide!.ratingAvg!.toStringAsFixed(1)} (${_guide!.ratingCount ?? 0} reviews)',
                                  style: const TextStyle(color: AppColors.amberStar, fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_guide!.phone != null && _guide!.phone!.isNotEmpty) ...[
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(_guide!.phone!, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                    if (_guide!.email != null && _guide!.email!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(_guide!.email!, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Actions
          if (canCancel) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _cancelBooking,
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                label: const Text('Cancel Hire Request', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (isAccepted) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (_booking?.tourGuideId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GuideLocationScreen(
                          guideId: _booking!.tourGuideId!,
                          guideName: _guide?.fullName ?? 'Tour Guide',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.navigation_rounded),
                label: const Text('Track Live Location'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tealSuccess,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (isAccepted && !isPaid) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _payNow,
                icon: const Icon(Icons.payment_rounded),
                label: const Text('Pay Guide Fee'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (isCompleted) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (_booking?.tourGuideId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RateGuideScreen(
                          guideId: _booking!.tourGuideId!,
                          guideName: _guide?.fullName ?? 'Tour Guide',
                          bookingId: _booking?.id,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.star_rate_rounded),
                label: const Text('Rate This Guide'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (isPaid) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _downloadInvoice,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Invoice (PDF)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 16 : 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
