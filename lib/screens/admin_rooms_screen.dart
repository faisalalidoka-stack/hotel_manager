import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/db_builder.dart';
import 'room_form_screen.dart';

// Admin: list, search, add, edit, hide and delete rooms
class AdminRoomsScreen extends StatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _type = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openForm([Room? room]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomFormScreen(room: room)),
    );
  }

  Future<void> _delete(Room room) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete ${room.name}?',
      message: 'This room will be removed permanently. This cannot be undone.',
    );
    if (!ok || !mounted) return;
    await runDb(
      context,
      () => DatabaseHelper.instance.deleteRoom(room.id!),
      success: 'Room deleted',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add room'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchField(
              controller: _searchCtrl,
              hint: 'Search rooms',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilterChips(
              options: roomTypes,
              selected: _type,
              onSelected: (t) => setState(() => _type = t),
            ),
          ),
          Expanded(
            child: DbBuilder<List<Room>>(
              load: () => DatabaseHelper.instance.getRooms(
                search: _query,
                type: _type,
                onlyAvailable: false,
              ),
              builder: (context, rooms) {
                if (rooms.isEmpty) {
                  return const EmptyView(
                    icon: Icons.bed_outlined,
                    title: 'No rooms found',
                    message: 'Add a room or change the search and filter.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: rooms.length,
                  itemBuilder: (_, i) {
                    final room = rooms[i];
                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () => _openForm(room),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: RoomImage(room: room, height: 72),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${room.type}  |  Sleeps ${room.capacity}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.muted),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        PriceText(
                                            amount: room.pricePerNight,
                                            size: 13),
                                        if (!room.available) ...[
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Hidden',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _openForm(room);
                                  } else if (value == 'toggle') {
                                    await runDb(
                                      context,
                                      () => DatabaseHelper.instance
                                          .setRoomAvailable(
                                              room.id!, !room.available),
                                      success: room.available
                                          ? 'Room hidden from guests'
                                          : 'Room is now visible to guests',
                                    );
                                  } else {
                                    await _delete(room);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(room.available
                                        ? 'Hide from guests'
                                        : 'Show to guests'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Delete',
                                      style:
                                          TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
