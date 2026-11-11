import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_card.dart';
import '../widgets/common.dart';
import '../widgets/db_builder.dart';

// Admin: every booking in the database, with status updates and delete
class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _status = 'All';
  String _sort = bookingSortOptions.first;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _setStatus(Booking b, String status) async {
    await runDb(
      context,
      () => DatabaseHelper.instance.updateBookingStatus(b.id!, status),
      success: 'Booking marked as ${status.toLowerCase()}',
    );
  }

  List<BookingAction> _actionsFor(Booking b) {
    return [
      if (b.status == 'Pending')
        BookingAction('Confirm', Icons.check_circle_outline,
            () => _setStatus(b, 'Confirmed')),
      if (b.status == 'Confirmed')
        BookingAction('Mark completed', Icons.done_all,
            () => _setStatus(b, 'Completed')),
      if (b.status == 'Pending' || b.status == 'Confirmed')
        BookingAction('Cancel booking', Icons.event_busy, () async {
          final ok = await confirmDialog(
            context,
            title: 'Cancel this booking?',
            message: 'Booking ${b.reference} for ${b.guestName} will be cancelled.',
            confirmLabel: 'Cancel booking',
          );
          if (ok && mounted) await _setStatus(b, 'Cancelled');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bookings'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchField(
              controller: _searchCtrl,
              hint: 'Search by guest, room or reference',
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
                              icon: Icons.event_busy,
                              title: 'No bookings found',
                              message: 'Try a different search or status.',
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 20),
                              children: [
                                for (final b in bookings)
                                  BookingCard(
                                    booking: b,
                                    showGuest: true,
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
