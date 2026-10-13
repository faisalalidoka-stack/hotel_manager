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
  String _selected = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = _selected == 'All'
        ? rooms
        : rooms.where((r) => r.type == _selected).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Rooms & Suites')),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: roomTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = roomTypes[i];
                final isSelected = t == _selected;
                return ChoiceChip(
                  label: Text(t),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _selected = t),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} ${filtered.length == 1 ? 'room' : 'rooms'} available',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => RoomCard(room: filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}