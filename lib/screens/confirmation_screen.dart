import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class ConfirmationScreen extends StatelessWidget {
  final Booking booking;
  const ConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Get first name from full name
    final firstName = booking.guestName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),

          // Big green check icon
          const Center(
            child: Icon(
              Icons.check_circle,
              size: 84,
              color: Color(0xFF2E9E6B),
            ),
          ),

          const SizedBox(height: 12),

          // Thank you message
          Center(
            child: Text(
              'Thank you, $firstName!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 4),

          const Center(
            child: Text(
              'Your stay at Pearl Suites is reserved.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),

          const SizedBox(height: 22),

          // Booking reference box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE3EEFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  'Booking Reference',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.reference,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Booking details card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _DetailLine('Room', booking.room.name),
                _DetailLine('Check-in', formatDate(booking.checkIn)),
                _DetailLine('Check-out', formatDate(booking.checkOut)),
                _DetailLine('Nights', '${booking.nights}'),
                _DetailLine('Guests', '${booking.guests}'),
                _DetailLine('Payment', booking.payment),
                const Divider(height: 24),
                _DetailLine('Total', formatUgx(booking.total), bold: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'A confirmation will be sent to ${booking.email}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              // Go all the way back to the home screen
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

// A label-value row for the booking details card
class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _DetailLine(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? AppColors.primary : AppColors.text,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
