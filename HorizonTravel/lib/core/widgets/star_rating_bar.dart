import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StarRatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int>? onRatingChanged;
  final int? count;

  const StarRatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 18.0,
    this.activeColor = AppColors.tertiary,
    this.inactiveColor = const Color(0xFFCBD5E1),
    this.onRatingChanged,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(maxRating, (index) {
      final starValue = index + 1;
      IconData icon;
      Color color;

      if (rating >= starValue) {
        icon = Icons.star_rounded;
        color = activeColor;
      } else if (rating >= starValue - 0.5) {
        icon = Icons.star_half_rounded;
        color = activeColor;
      } else {
        icon = Icons.star_outline_rounded;
        color = inactiveColor;
      }

      final starWidget = Icon(icon, size: size, color: color);

      if (onRatingChanged != null) {
        return GestureDetector(
          onTap: () => onRatingChanged!(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: starWidget,
          ),
        );
      }
      return starWidget;
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...stars,
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(
            '${rating.toStringAsFixed(1)} ($count)',
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
