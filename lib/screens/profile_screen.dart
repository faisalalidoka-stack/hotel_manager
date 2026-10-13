import 'package:flutter/material.dart';
import '../data/booking_store.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _pastStays = [
    ('Executive Lake View', '3 – 5 Aug 2026', 'UGX 840,000'),
    ('Deluxe Garden View', '12 – 14 Mar 2026', 'UGX 560,000'),
  ];

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This section is coming in the next update.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.gold,
                      child: Text('S',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guestName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text(guestEmail,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(guestPhone,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.workspace_premium,
                          color: AppColors.gold, size: 20),
                      SizedBox(width: 8),
                      Text('Gold member',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      Spacer(),
                      Text('1,250 points',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('My bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<Booking>>(
            valueListenable: BookingStore.bookings,
            builder: (context, list, _) {
              if (list.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.luggage_outlined, color: AppColors.muted),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No upcoming bookings yet. Browse rooms to plan your next stay.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: list
                    .map((b) => Card(
                  color: Colors.white,
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      AppColors.primary.withOpacity(0.1),
                      child: Icon(b.room.icon,
                          color: AppColors.primary, size: 20),
                    ),
                    title: Text(b.room.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${formatDate(b.checkIn)} → ${formatDate(b.checkOut)}\nRef: ${b.reference}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      formatUgx(b.total),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary),
                    ),
                  ),
                ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          const Text('Past stays',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ..._pastStays.map(
                (s) => Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFEFEF),
                  child: Icon(Icons.history, color: AppColors.muted, size: 20),
                ),
                title: Text(s.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(s.$2),
                trailing: Text(s.$3,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _MenuTile(
                    icon: Icons.person_outline,
                    title: 'Personal details',
                    onTap: () => _comingSoon(context)),
                const Divider(height: 1),
                _MenuTile(
                    icon: Icons.payment,
                    title: 'Payment methods',
                    onTap: () => _comingSoon(context)),
                const Divider(height: 1),
                _MenuTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () => _comingSoon(context)),
                const Divider(height: 1),
                _MenuTile(
                    icon: Icons.help_outline,
                    title: 'Help & support',
                    onTap: () => _comingSoon(context)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sign out?'),
                content: const Text('You can sign back in at any time.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Sign out')),
                ],
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: onTap,
    );
  }
}