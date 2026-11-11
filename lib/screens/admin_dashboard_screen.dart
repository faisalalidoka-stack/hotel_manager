import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/session.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/db_builder.dart';
import 'room_form_screen.dart';

// Admin home: reports calculated from the saved database records
class AdminDashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context),
          ),
        ],
      ),
      body: DbBuilder<DashboardData>(
        load: () => DatabaseHelper.instance.dashboard(),
        builder: (context, data) {
          final s = data.summary;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.accent,
                      child: Icon(Icons.admin_panel_settings,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome,',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          Text(
                            Session.user?.fullName ?? 'Manager',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Summary tiles
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatTile(Icons.event_note, 'Total bookings', '${s.total}'),
                  _StatTile(Icons.payments_outlined, 'Booked value',
                      formatUgx(s.totalValue)),
                  _StatTile(Icons.bed_outlined, 'Rooms', '${data.roomCount}'),
                  _StatTile(Icons.people_outline, 'Guests', '${data.guestCount}'),
                ],
              ),

              const SizedBox(height: 22),

              // Bookings by status
              const Text('Bookings by status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: s.total == 0
                    ? const Text('No bookings yet.',
                        style: TextStyle(color: AppColors.muted))
                    : Column(
                        children: [
                          for (final status in bookingStatuses)
                            _StatusBar(
                              status: status,
                              count: s.countOf(status),
                              total: s.total,
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 22),

              // Revenue by room type
              const Text('Revenue by room type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (final row in data.revenueByType)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(row.type,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                    '${row.bookings} ${row.bookings == 1 ? 'booking' : 'bookings'}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatUgx(row.revenue),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Quick actions
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoomFormScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add a new room'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => onNavigate(2),
                icon: const Icon(Icons.pending_actions),
                label: Text('Review bookings (${s.countOf('Pending')} pending)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String status;
  final int count;
  final int total;
  const _StatusBar({
    required this.status,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusChip.colorFor(status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('$count', style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : count / total,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
