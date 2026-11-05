import 'package:flutter/material.dart';
import '../data/static_data.dart';
import '../theme/app_theme.dart';
import '../widgets/room_card.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  // Which room type filter is currently selected
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    // Filter rooms by selected type, or show all
    final filteredRooms = _selectedType == 'All'
        ? rooms
        : rooms.where((r) => r.type == _selectedType).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Rooms and Suites')),
      body: Column(
        children: [
          // Filter chips row
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: roomTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final type = roomTypes[i];
                final isSelected = type == _selectedType;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedType = type);
                  },
                );
              },
            ),
          ),

          // Room count label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredRooms.length} ${filteredRooms.length == 1 ? 'room' : 'rooms'} available',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ),

          // Rooms list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: filteredRooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                return RoomCard(room: filteredRooms[i]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
