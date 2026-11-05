import 'package:flutter/material.dart';
import '../data/booking_store.dart';
import '../data/static_data.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Sample past stays shown as history
  static const List<Map<String, String>> _pastStays = [
    {
      'name': 'Executive Lake View',
      'dates': '3 - 5 Aug 2026',
      'amount': 'UGX 840,000',
    },
    {
      'name': 'Deluxe Garden View',
      'dates': '12 - 14 Mar 2026',
      'amount': 'UGX 560,000',
    },
  ];

  // Show a snack bar for features not yet built
  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This section is coming in the next update.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    // Avatar circle
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.accent,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guestName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            guestEmail,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            guestPhone,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Loyalty points row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Gold Member',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '1,250 points',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // My bookings section
          const Text(
            'My Bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // Show bookings from the store
          _BookingsList(),

          const SizedBox(height: 14),

          // Past stays section
          const Text(
            'Past Stays',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // Loop through past stays list
          for (final stay in _pastStays)
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
                  child: Icon(Icons.history, color: AppColors.muted, size: 20),
                ),
                title: Text(
                  stay['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(stay['dates']!),
                trailing: Text(
                  stay['amount']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Account settings section
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
                  title: 'Personal Details',
                  onTap: () => _comingSoon(context),
                ),
                const Divider(height: 1),
                _MenuRow(
                  icon: Icons.payment,
                  title: 'Payment Methods',
                  onTap: () => _comingSoon(context),
                ),
                const Divider(height: 1),
                _MenuRow(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () => _comingSoon(context),
                ),
                const Divider(height: 1),
                _MenuRow(
                  icon: Icons.help_outline,
                  title: 'Help and Support',
                  onTap: () => _comingSoon(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sign out button
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text('You can sign back in at any time.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
            },
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

// Separate widget to show upcoming bookings list
class _BookingsList extends StatefulWidget {
  @override
  State<_BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<_BookingsList> {
  @override
  void initState() {
    super.initState();
    // Listen for new bookings and rebuild this widget
    BookingStore.bookings.addListener(_onBookingsChanged);
  }

  @override
  void dispose() {
    BookingStore.bookings.removeListener(_onBookingsChanged);
    super.dispose();
  }

  void _onBookingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bookingList = BookingStore.bookings.value;

    if (bookingList.isEmpty) {
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
      children: bookingList.map((booking) {
        return Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE3EEFF),
              child: Icon(
                booking.room.icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              booking.room.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${formatDate(booking.checkIn)} to ${formatDate(booking.checkOut)}\nRef: ${booking.reference}',
            ),
            isThreeLine: true,
            trailing: Text(
              formatUgx(booking.total),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
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
