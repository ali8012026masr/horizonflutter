import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/cart_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../theme/app_colors.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          Consumer<CartManager>(
            builder: (context, cart, _) {
              if (cart.count == 0) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear Cart',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Clear Cart',
                    message: 'Are you sure you want to remove all items from your cart?',
                    positiveText: 'Clear',
                    isDestructive: true,
                  );
                  if (confirmed) {
                    cart.clear();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartManager>(
        builder: (context, cart, _) {
          if (cart.count == 0) {
            return const EmptyStateView(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your Cart is Empty',
              message: 'Explore services and add them to your cart to book your trips.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final slot = cart.items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.directions_bus, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      StatusChip(status: slot.category ?? 'SERVICE'),
                                      Text(
                                        Formatters.formatCurrency(slot.price ?? 0),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slot.providerBusinessName ?? 'Service Slot',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    slot.origin != null && slot.destination != null
                                        ? '${slot.origin} → ${slot.destination}'
                                        : (slot.locationName ?? ''),
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatters.formatDateTime(slot.startDateTime),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove',
                              icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                              onPressed: () {
                                if (slot.id != null) {
                                  cart.removeItem(slot.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutBar(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartManager cart) {
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
                Text(
                  '${cart.count} item${cart.count > 1 ? "s" : ""}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  Formatters.formatCurrency(cart.totalPrice),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(slots: cart.items),
                  ),
                );
              },
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
