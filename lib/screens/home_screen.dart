import 'package:flutter/material.dart';
import '../data/static_data.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/room_card.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Get only featured rooms
    final featuredRooms = rooms.where((r) => r.featured).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top header section
            _Header(onNavigate: onNavigate),

            // Featured rooms section
            SectionTitle(
              title: 'Featured Rooms',
              actionLabel: 'See all',
              onAction: () => onNavigate(1),
            ),
            SizedBox(
              height: 252,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: featuredRooms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  return RoomCard(room: featuredRooms[i], compact: true);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Weekend offer banner
            _OfferBanner(onTap: () => onNavigate(1)),

            // Hotel services section
            const SectionTitle(title: 'Hotel Services'),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 112,
              ),
              itemBuilder: (_, i) {
                final service = services[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE3EEFF),
                        child: Icon(service.icon, size: 20, color: AppColors.primary),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            service.price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Contact/help box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent, color: AppColors.primary, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need help planning your stay?',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Reception: +256 414 000 000  |  24 hours',
                          style: TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// Header widget with gradient background and search card
class _Header extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _Header({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final checkIn = DateTime(now.year, now.month, now.day + 1);
    final checkOut = DateTime(now.year, now.month, now.day + 3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Welcome row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      guestName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                // Avatar button to go to profile
                GestureDetector(
                  onTap: () => onNavigate(2),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Tagline
            const Text(
              'Find your perfect\nstay in Kampala',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 18),

            // Search / booking card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Location row
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Pearl Suites - Kololo, Kampala',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Dates and guests row
                  Row(
                    children: [
                      _InfoItem(label: 'Check-in', value: formatDate(checkIn)),
                      _InfoItem(label: 'Check-out', value: formatDate(checkOut)),
                      const _InfoItem(label: 'Guests', value: '2 adults'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => onNavigate(1),
                    child: const Text('Check availability'),
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

// Small info item used in the date/guest row
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// Promo banner for weekend offer
class _OfferBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _OfferBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekend Escape',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Save 15% on Friday to Sunday stays. Breakfast for two included.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.local_offer, size: 44, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
