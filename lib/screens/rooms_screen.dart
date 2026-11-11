import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/db_builder.dart';
import '../widgets/room_card.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedType = 'All';
  String _sort = roomSortOptions.first;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms and Suites')),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchField(
              controller: _searchCtrl,
              hint: 'Search rooms, e.g. lake, family, suite',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Type filter chips
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilterChips(
              options: roomTypes,
              selected: _selectedType,
              onSelected: (t) => setState(() => _selectedType = t),
            ),
          ),

          // Results are loaded from the database using the search,
          // filter and sort choices above
          Expanded(
            child: DbBuilder<List<Room>>(
              load: () => DatabaseHelper.instance.getRooms(
                search: _query,
                type: _selectedType,
                sort: _sort,
              ),
              builder: (context, rooms) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${rooms.length} ${rooms.length == 1 ? 'room' : 'rooms'} available',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 13),
                          ),
                          SortMenu(
                            options: roomSortOptions,
                            value: _sort,
                            onChanged: (v) => setState(() => _sort = v),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: rooms.isEmpty
                          ? const EmptyView(
                              icon: Icons.search_off,
                              title: 'No rooms found',
                              message:
                                  'Try a different search word or filter.',
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 20),
                              itemCount: rooms.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (_, i) =>
                                  RoomCard(room: rooms[i]),
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
