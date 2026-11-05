import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/room_details_screen.dart';
import '../theme/app_theme.dart';
import 'common.dart';

// A card showing a room photo, name, capacity and price
class RoomCard extends StatelessWidget {
  final Room room;
  final bool compact; // compact = smaller card for horizontal list
  const RoomCard({super.key, required this.room, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Open the room details screen when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomDetailsScreen(room: room),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room photo
            RoomImage(room: room, height: compact ? 130 : 180),

            // Room name, capacity and price
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 15,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sleeps ${room.capacity}  |  ${room.sizeSqm} m2',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PriceText(amount: room.pricePerNight, size: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Compact cards have a fixed width for horizontal scrolling
    if (compact) {
      return SizedBox(width: 240, child: card);
    }
    return card;
  }
}
