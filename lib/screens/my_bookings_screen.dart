import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/session.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/booking_card.dart';
import '../widgets/common.dart';
import '../widgets/db_builder.dart';
import 'booking_screen.dart';

// Guest screen: all bookings saved in the database for the logged in user
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _status = 'All';
  String _sort = bookingSortOptions.first;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BookingAction> _actionsFor(Booking b) {
    return [
      if (b.isEditable)
        BookingAction('Edit booking', Icons.edit_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingScreen(room: b.room, existing: b),
            ),
          );
        }),
      if (b.isEditable)
        BookingAction('Cancel booking', Icons.event_busy, () async {
          final ok = await confirmDialog(
            context,
            title: 'Cancel this booking?',
            message: 'Booking ${b.reference} will be marked as cancelled.',
            confirmLabel: 'Cancel booking',
          );
          if (!ok || !mounted) return;
          await runDb(
            context,
            () => DatabaseHelper.instance.updateBookingStatus(b.id!, 'Cancelled'),
            success: 'Booking cancelled',
          );
        }),
      BookingAction('Delete', Icons.delete_outline, () async {
        final ok = await confirmDialog(
          context,
          title: 'Delete this booking?',
          message:
              'Booking ${b.reference} will be removed permanently. This cannot be undone.',
        );
        if (!ok || !mounted) return;
        await runDb(
          context,
          () => DatabaseHelper.instance.deleteBooking(b.id!),
          success: 'Booking deleted',
        );
      }, destructive: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userId = Session.user?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Column(
        children: [
          // Summary calculated by SQL from the saved bookings
          DbBuilder<BookingSummary>(
            load: () => DatabaseHelper.instance.bookingSummary(userId: userId),
            builder: (context, s) => Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _Stat('Bookings', '${s.total}'),
                  _Stat('Upcoming',
                      '${s.countOf('Pending') + s.countOf('Confirmed')}'),
                  _Stat('Total value', formatUgx(s.totalValue), wide: true),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchField(
              controller: _searchCtrl,
              hint: 'Search by room or reference',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilterChips(
              options: ['All', ...bookingStatuses],
              selected: _status,
              onSelected: (v) => setState(() => _status = v),
            ),
          ),

          Expanded(
            child: DbBuilder<List<Booking>>(
              load: () => DatabaseHelper.instance.getBookings(
                userId: userId,
                status: _status,
                search: _query,
                sort: _sort,
              ),
              builder: (context, bookings) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${bookings.length} ${bookings.length == 1 ? 'booking' : 'bookings'}',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 13),
                          ),
                          SortMenu(
                            options: bookingSortOptions,
                            value: _sort,
                            onChanged: (v) => setState(() => _sort = v),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: bookings.isEmpty
                          ? const EmptyView(
                              icon: Icons.luggage_outlined,
                              title: 'No bookings found',
                              message:
                                  'Browse rooms to plan your next stay, or change the filters.',
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 20),
                              children: [
                                for (final b in bookings)
                                  BookingCard(
                                    booking: b,
                                    actions: _actionsFor(b),
                                  ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool wide;
  const _Stat(this.label, this.value, {this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: wide ? 2 : 1,
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
