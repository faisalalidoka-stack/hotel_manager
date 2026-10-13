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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(room.name, style: const TextStyle(fontSize: 16)),
              background: RoomImage(room: room, height: 280),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          room.type,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 18, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        '${room.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '  (${room.reviews} reviews)',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Spec(
                            icon: Icons.square_foot,
                            value: '${room.sizeSqm} m²',
                            label: 'Room size'),
                        _Spec(
                            icon: Icons.bed_outlined,
                            value: room.bed,
                            label: 'Bed'),
                        _Spec(
                            icon: Icons.people_outline,
                            value: '${room.capacity} guests',
                            label: 'Capacity'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('About this room',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    room.description,
                    style: const TextStyle(
                        height: 1.5, color: AppColors.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 22),
                  const Text('Facilities',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                      final f = room.facilities[i];
                      return Row(
                        children: [
                          Icon(f.icon, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f.label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        _Policy(
                            icon: Icons.login,
                            text: 'Check-in from 2:00 PM'),
                        SizedBox(height: 10),
                        _Policy(
                            icon: Icons.logout,
                            text: 'Check-out by 11:00 AM'),
                        SizedBox(height: 10),
                        _Policy(
                            icon: Icons.event_available,
                            text: 'Free cancellation up to 48 hours before'),
                        SizedBox(height: 10),
                        _Policy(
                            icon: Icons.receipt_long,
                            text: 'Prices include 18% VAT'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From',
                      style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  PriceText(amount: room.pricePerNight, size: 17),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingScreen(room: room)),
                  ),
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

class _Spec extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Spec({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }
}

class _Policy extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Policy({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gold),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}