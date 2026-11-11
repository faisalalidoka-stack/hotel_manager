import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/db_builder.dart';

// Admin: registered guests with their number of bookings
class AdminGuestsScreen extends StatefulWidget {
  const AdminGuestsScreen({super.key});

  @override
  State<AdminGuestsScreen> createState() => _AdminGuestsScreenState();
}

class _AdminGuestsScreenState extends State<AdminGuestsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _delete(AppUser guest) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete ${guest.fullName}?',
      message:
          'This guest account and all ${guest.bookingCount} of their bookings will be removed permanently.',
    );
    if (!ok || !mounted) return;
    await runDb(
      context,
      () => DatabaseHelper.instance.deleteUser(guest.id!),
      success: 'Guest deleted',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guests'),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchField(
              controller: _searchCtrl,
              hint: 'Search by name, email or phone',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: DbBuilder<List<AppUser>>(
              load: () => DatabaseHelper.instance.getGuests(search: _query),
              builder: (context, guests) {
                if (guests.isEmpty) {
                  return const EmptyView(
                    icon: Icons.people_outline,
                    title: 'No guests found',
                    message: 'Guests appear here after they register.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: guests.length,
                  itemBuilder: (_, i) {
                    final g = guests[i];
                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            g.fullName.isEmpty
                                ? '?'
                                : g.fullName[0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(g.fullName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            '${g.email}\n${g.phone}  |  ${g.bookingCount} ${g.bookingCount == 1 ? 'booking' : 'bookings'}'),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Delete guest',
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red.shade700),
                          onPressed: () => _delete(g),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
