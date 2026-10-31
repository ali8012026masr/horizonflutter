import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../formatting/formatters.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final String? label;
  final double fontSize;

  const StatusChip({
    super.key,
    String? status,
    String? label,
    this.fontSize = 11.5,
  })  : status = status ?? label ?? '',
        label = label;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg = Colors.white;

    final upper = status.toUpperCase();
    if (upper == 'ACTIVE' ||
        upper == 'APPROVED' ||
        upper == 'CONFIRMED' ||
        upper == 'PAID' ||
        upper == 'SUCCESS' ||
        upper == 'COMPLETED' ||
        upper == 'OPEN' ||
        upper == 'SETTLED' ||
        upper == 'ACCEPTED') {
      bg = AppColors.statusActive;
    } else if (upper == 'PENDING' ||
        upper == 'PENDING_VERIFICATION' ||
        upper == 'REQUESTED' ||
        upper.contains('PENDING')) {
      bg = AppColors.statusPending;
    } else if (upper == 'REJECTED' ||
        upper == 'REVOKED' ||
        upper == 'CANCELLED' ||
        upper == 'DECLINED' ||
        upper == 'FAILED' ||
        upper == 'ERROR') {
      bg = AppColors.statusError;
    } else if (upper == 'SUSPENDED' ||
        upper == 'CLOSED' ||
        upper == 'FULL') {
      bg = AppColors.statusSuspended;
    } else {
      bg = AppColors.badgeNeutral;
    }

    final displayText = label ?? Formatters.capitalizeEnum(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
