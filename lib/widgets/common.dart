import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Shows the room photo if the asset exists, otherwise a themed gradient.
class RoomImage extends StatelessWidget {
  final Room room;
  final double height;
  const RoomImage({super.key, required this.room, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        room.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: room.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(room.icon, size: 56, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

class PriceText extends StatelessWidget {
  final int amount;
  final double size;
  final bool showSuffix;
  const PriceText({
    super.key,
    required this.amount,
    this.size = 16,
    this.showSuffix = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: formatUgx(amount),
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        children: [
          if (showSuffix)
            const TextSpan(
              text: ' /night',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}