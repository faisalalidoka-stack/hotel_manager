import 'package:flutter/material.dart';

class Facility {
  final String label;
  final IconData icon;
  const Facility(this.label, this.icon);
}

// Facilities are stored in the database as comma-separated keys.
// This catalog turns each key into a label and an icon.
const Map<String, Facility> facilityCatalog = {
  'wifi': Facility('Free Wi-Fi', Icons.wifi),
  'ac': Facility('Air conditioning', Icons.ac_unit),
  'tv': Facility('Smart TV', Icons.tv),
  'shower': Facility('Hot shower', Icons.shower),
  'coffee': Facility('Tea and coffee', Icons.coffee),
  'breakfast': Facility('Breakfast included', Icons.free_breakfast),
  'desk': Facility('Work desk', Icons.desk),
  'safe': Facility('In-room safe', Icons.lock),
  'minibar': Facility('Mini bar', Icons.local_bar),
  'balcony': Facility('Private balcony', Icons.balcony),
  'bath': Facility('Bathtub', Icons.bathtub),
  'jacuzzi': Facility('Jacuzzi', Icons.hot_tub),
  'parking': Facility('Free parking', Icons.local_parking),
  'pool': Facility('Pool access', Icons.pool),
  'kitchen': Facility('Kitchenette', Icons.kitchen),
  'service': Facility('24h room service', Icons.room_service),
};

// Colours and icon for each room type (used when a room has no photo)
const Map<String, List<Color>> typeGradients = {
  'Standard': [Color(0xFF1976D2), Color(0xFF1565C0)],
  'Deluxe': [Color(0xFF26A69A), Color(0xFF00796B)],
  'Executive': [Color(0xFF1565C0), Color(0xFF0D47A1)],
  'Family': [Color(0xFFFF8F00), Color(0xFFE65100)],
  'Suite': [Color(0xFF7B1FA2), Color(0xFF4A148C)],
};

const Map<String, IconData> typeIcons = {
  'Standard': Icons.bed,
  'Deluxe': Icons.king_bed,
  'Executive': Icons.king_bed,
  'Family': Icons.family_restroom,
  'Suite': Icons.star,
};

class Room {
  final int? id;
  final String name;
  final String type;
  final String description;
  final String bed;
  final String imagePath;
  final int pricePerNight;
  final int sizeSqm;
  final int capacity;
  final double rating;
  final int reviews;
  final List<String> facilityKeys;
  final bool featured;
  final bool available;

  const Room({
    this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.bed,
    required this.imagePath,
    required this.pricePerNight,
    required this.sizeSqm,
    required this.capacity,
    this.rating = 0,
    this.reviews = 0,
    required this.facilityKeys,
    this.featured = false,
    this.available = true,
  });

  // Derived values used by the existing screens
  List<Facility> get facilities => facilityKeys
      .where((k) => facilityCatalog.containsKey(k))
      .map((k) => facilityCatalog[k]!)
      .toList();

  List<Color> get gradient =>
      typeGradients[type] ?? const [Color(0xFF1976D2), Color(0xFF1565C0)];

  IconData get icon => typeIcons[type] ?? Icons.bed;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'description': description,
        'bed': bed,
        'image_path': imagePath,
        'price_per_night': pricePerNight,
        'size_sqm': sizeSqm,
        'capacity': capacity,
        'rating': rating,
        'reviews': reviews,
        'facilities': facilityKeys.join(','),
        'featured': featured ? 1 : 0,
        'available': available ? 1 : 0,
      };

  factory Room.fromMap(Map<String, Object?> m) {
    final raw = (m['facilities'] as String?) ?? '';
    return Room(
      id: m['id'] as int?,
      name: m['name'] as String,
      type: m['type'] as String,
      description: m['description'] as String,
      bed: m['bed'] as String,
      imagePath: m['image_path'] as String,
      pricePerNight: m['price_per_night'] as int,
      sizeSqm: m['size_sqm'] as int,
      capacity: m['capacity'] as int,
      rating: (m['rating'] as num).toDouble(),
      reviews: m['reviews'] as int,
      facilityKeys: raw.isEmpty ? <String>[] : raw.split(','),
      featured: (m['featured'] as int) == 1,
      available: (m['available'] as int) == 1,
    );
  }
}

class HotelService {
  final String title;
  final String price;
  final IconData icon;
  const HotelService(this.title, this.price, this.icon);
}

class AppUser {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'guest' or 'admin'
  final int bookingCount; // only filled by the admin guest list query

  const AppUser({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.bookingCount = 0,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as int?,
        fullName: m['full_name'] as String,
        email: m['email'] as String,
        phone: m['phone'] as String,
        role: m['role'] as String,
        bookingCount: (m['booking_count'] as int?) ?? 0,
      );
}

class Booking {
  final int? id;
  final String reference;
  final int userId;
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String guestName;
  final String email;
  final String phone;
  final String payment;
  final String requests;
  final String status; // Pending, Confirmed, Completed, Cancelled
  final int total;

  const Booking({
    this.id,
    required this.reference,
    required this.userId,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.guestName,
    required this.email,
    required this.phone,
    required this.payment,
    required this.requests,
    required this.status,
    required this.total,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  // A booking can only be edited or cancelled while it is still upcoming
  bool get isEditable {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (status == 'Pending' || status == 'Confirmed') &&
        !checkIn.isBefore(today);
  }

  factory Booking.fromMap(Map<String, Object?> m, Room room) => Booking(
        id: m['id'] as int?,
        reference: m['reference'] as String,
        userId: m['user_id'] as int,
        room: room,
        checkIn: DateTime.parse(m['check_in'] as String),
        checkOut: DateTime.parse(m['check_out'] as String),
        guests: m['guests'] as int,
        guestName: m['guest_name'] as String,
        email: m['email'] as String,
        phone: m['phone'] as String,
        payment: m['payment'] as String,
        requests: (m['requests'] as String?) ?? '',
        status: m['status'] as String,
        total: m['total'] as int,
      );
}

// Results of SQL summary queries
class BookingSummary {
  final Map<String, int> countByStatus;
  final int totalValue; // sum of non-cancelled bookings

  const BookingSummary({
    required this.countByStatus,
    required this.totalValue,
  });

  int get total => countByStatus.values.fold(0, (a, b) => a + b);
  int countOf(String status) => countByStatus[status] ?? 0;
}

class RevenueRow {
  final String type;
  final int bookings;
  final int revenue;
  const RevenueRow(this.type, this.bookings, this.revenue);
}

class DashboardData {
  final BookingSummary summary;
  final int roomCount;
  final int guestCount;
  final List<RevenueRow> revenueByType;

  const DashboardData({
    required this.summary,
    required this.roomCount,
    required this.guestCount,
    required this.revenueByType,
  });
}
