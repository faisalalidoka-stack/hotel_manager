import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/session.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/db_builder.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _editProfile() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (changed == true && mounted) setState(() {});
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help and Support'),
        content: const Text(
          'Reception is open 24 hours.\n\n'
          'Phone: +256 414 000 000\n'
          'Email: reservations@pearlsuites.com\n'
          'Address: Kololo, Kampala',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.user!;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile card
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
                      backgroundColor: AppColors.accent,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            user.phone,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Loyalty points: 1 point for every UGX 1,000 booked
                DbBuilder<BookingSummary>(
                  load: () => DatabaseHelper.instance
                      .bookingSummary(userId: user.id),
                  builder: (context, s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Pearl Rewards',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          '${formatNumber(s.totalValue ~/ 1000)} points',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Past stays are completed bookings read from the database
          const Text(
            'Past Stays',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          DbBuilder<List<Booking>>(
            load: () => DatabaseHelper.instance
                .getBookings(userId: user.id, status: 'Completed'),
            builder: (context, stays) {
              if (stays.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.history, color: AppColors.muted),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No completed stays yet.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final stay in stays)
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEEEEEE),
                          child: Icon(Icons.history,
                              color: AppColors.muted, size: 20),
                        ),
                        title: Text(
                          stay.room.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                            '${formatDate(stay.checkIn)} - ${formatDate(stay.checkOut)}'),
                        trailing: Text(
                          formatUgx(stay.total),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: _editProfile,
                ),
                const Divider(height: 1),
                _MenuRow(
                  icon: Icons.help_outline,
                  title: 'Help and Support',
                  onTap: _showHelp,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () => signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// A single menu row item
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

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
