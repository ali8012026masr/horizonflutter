import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/cart_manager.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/service_slot.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';
import 'booking_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<ServiceSlot> slots;

  const CheckoutScreen({super.key, required this.slots});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _apiService = ApiService();
  String _selectedPaymentMethod = PaymentMethod.card;
  bool _isProcessing = false;
  String _progressMessage = 'Processing booking…';

  double get _totalAmount {
    double total = 0.0;
    for (final s in widget.slots) {
      total += (s.price ?? 0.0);
    }
    return total;
  }

  Future<void> _processCheckout() async {
    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in as a tourist to complete booking.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _progressMessage = 'Reserving your slots…';
    });

    final List<Booking> successfulBookings = [];
    final List<Payment> successfulPayments = [];
    final List<String> errors = [];

    for (int i = 0; i < widget.slots.length; i++) {
      final slot = widget.slots[i];
      if (slot.id == null) continue;

      setState(() {
        _progressMessage = 'Booking item ${i + 1} of ${widget.slots.length}…';
      });

      try {
        // 1. Create booking
        final bookingReq = BookingRequest(touristId: userId, serviceSlotId: slot.id!);
        final booking = await _apiService.createBooking(bookingReq);
        successfulBookings.add(booking);

        // 2. Remove from cart immediately to prevent double booking on partial failure
        await CartManager.instance.removeItem(slot.id!);

        // 3. Create payment
        if (booking.id != null) {
          setState(() {
            _progressMessage = 'Processing payment for item ${i + 1}…';
          });
          final payReq = PaymentRequest(
            bookingId: booking.id,
            amount: slot.price ?? 0.0,
            method: _selectedPaymentMethod,
          );
          final payment = await _apiService.createPayment(payReq);
          successfulPayments.add(payment);
        }
      } catch (e) {
        errors.add('${slot.providerBusinessName ?? "Slot #${slot.id}"}: $e');
      }
    }

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (successfulBookings.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            bookingsCount: successfulBookings.length,
            totalAmount: _totalAmount,
            paymentMethod: _selectedPaymentMethod,
            hasErrors: errors.isNotEmpty,
            errorDetails: errors.join('\n'),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errors.isNotEmpty ? errors.first : 'Failed to process bookings. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: LoadingOverlay(
        isLoading: _isProcessing,
        message: _progressMessage,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...widget.slots.map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.providerBusinessName ?? 'Service Slot',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      if (s.origin != null && s.destination != null)
                                        Text(
                                          '${s.origin} → ${s.destination}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  Formatters.formatCurrency(s.price ?? 0),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Formatters.formatCurrency(_totalAmount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Card
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Credit / Debit Card'),
                      subtitle: const Text('Visa, Mastercard, AMEX'),
                      secondary: const Icon(Icons.credit_card, color: AppColors.primary),
                      value: PaymentMethod.card,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Mobile Banking'),
                      subtitle: const Text('bKash, Nagad, Rocket'),
                      secondary: const Icon(Icons.phone_android, color: AppColors.tealSecondary),
                      value: PaymentMethod.mobileBanking,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Cash on Arrival'),
                      subtitle: const Text('Pay provider directly at pickup/check-in'),
                      secondary: const Icon(Icons.money, color: AppColors.tertiary),
                      value: PaymentMethod.cash,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _isProcessing ? null : _processCheckout,
                child: Text('Confirm & Pay (${Formatters.formatCurrency(_totalAmount)})'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
