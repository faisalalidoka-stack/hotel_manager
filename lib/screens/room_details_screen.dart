import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'booking_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final Room room;
  const RoomDetailsScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room photo
            RoomImage(room: room, height: 240),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room type badge and rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          room.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 18, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        room.reviews == 0 ? 'New' : '${room.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        room.reviews == 0 ? '' : '  (${room.reviews} reviews)',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Room specs: size, bed, capacity
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SpecItem(
                          icon: Icons.square_foot,
                          value: '${room.sizeSqm} m2',
                          label: 'Room size',
                        ),
                        _SpecItem(
                          icon: Icons.bed_outlined,
                          value: room.bed,
                          label: 'Bed',
                        ),
                        _SpecItem(
                          icon: Icons.people_outline,
                          value: '${room.capacity} guests',
                          label: 'Capacity',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // About section
                  const Text(
                    'About this room',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.description,
                    style: const TextStyle(
                      height: 1.5,
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Facilities section
                  const Text(
                    'Facilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: room.facilities.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 38,
                    ),
                    itemBuilder: (_, i) {
                      final facility = room.facilities[i];
                      return Row(
                        children: [
                          Icon(
                            facility.icon,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              facility.label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Policies section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        _PolicyItem(
                          icon: Icons.login,
                          text: 'Check-in from 2:00 PM',
                        ),
                        SizedBox(height: 10),
                        _PolicyItem(
                          icon: Icons.logout,
                          text: 'Check-out by 11:00 AM',
                        ),
                        SizedBox(height: 10),
                        _PolicyItem(
                          icon: Icons.event_available,
                          text: 'Free cancellation up to 48 hours before',
                        ),
                        SizedBox(height: 10),
                        _PolicyItem(
                          icon: Icons.receipt_long,
                          text: 'Prices include 18% VAT',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom bar with price and book button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  PriceText(amount: room.pricePerNight, size: 17),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(room: room),
                      ),
                    );
                  },
                  child: const Text('Book now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Shows icon, value and label stacked vertically
class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _SpecItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

// A single policy row with icon and text
class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PolicyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
