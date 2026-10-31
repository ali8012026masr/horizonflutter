import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../theme/app_colors.dart';
import '../tourist_main_shell.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final int bookingsCount;
  final double totalAmount;
  final String paymentMethod;
  final bool hasErrors;
  final String? errorDetails;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingsCount,
    required this.totalAmount,
    required this.paymentMethod,
    this.hasErrors = false,
    this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 72,
                  color: AppColors.statusActive,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Successfully processed $bookingsCount service booking${bookingsCount > 1 ? "s" : ""}.',
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Paid', style: TextStyle(color: AppColors.textSecondary)),
                          Text(
                            Formatters.formatCurrency(totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Method', style: TextStyle(color: AppColors.textSecondary)),
                          Text(
                            Formatters.capitalizeEnum(paymentMethod),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (hasErrors && errorDetails != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Note: Some items had issues:\n$errorDetails',
                    style: const TextStyle(fontSize: 12, color: AppColors.onPrimaryContainer),
                  ),
                ),
              ],

              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.bookmark_border),
                label: const Text('View My Bookings'),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const TouristMainShell(initialTabIndex: 2),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const TouristMainShell(initialTabIndex: 0),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
