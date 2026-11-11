import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'common.dart';

// One item in the "..." menu of a booking card
class BookingAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
  const BookingAction(
    this.label,
    this.icon,
    this.onTap, {
    this.destructive = false,
  });
}

// Card showing one saved booking. Used by guests and by the admin.
class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool showGuest;
  final List<BookingAction> actions;
  const BookingCard({
    super.key,
    required this.booking,
    this.showGuest = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(booking.room.icon,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        'Ref: ${booking.reference}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: booking.status),
                if (actions.isNotEmpty)
                  PopupMenuButton<int>(
                    onSelected: (i) => actions[i].onTap(),
                    itemBuilder: (_) => [
                      for (var i = 0; i < actions.length; i++)
                        PopupMenuItem<int>(
                          value: i,
                          child: Row(
                            children: [
                              Icon(
                                actions[i].icon,
                                size: 18,
                                color: actions[i].destructive
                                    ? Colors.red.shade700
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(actions[i].label),
                            ],
                          ),
                        ),
                    ],
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showGuest) ...[
                    _Line(Icons.person_outline, booking.guestName),
                    const SizedBox(height: 4),
                  ],
                  _Line(
                    Icons.calendar_today,
                    '${formatDate(booking.checkIn)}  to  ${formatDate(booking.checkOut)}  (${booking.nights} ${booking.nights == 1 ? 'night' : 'nights'})',
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _Line(Icons.people_outline,
                            '${booking.guests} ${booking.guests == 1 ? 'guest' : 'guests'}  |  ${booking.payment}'),
                      ),
                      Text(
                        formatUgx(booking.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Line(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.text),
          ),
        ),
      ],
    );
  }
}
