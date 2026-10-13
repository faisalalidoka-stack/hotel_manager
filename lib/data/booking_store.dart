import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// In-memory only. Resets when the app restarts (no database by design).
class BookingStore {
  static final ValueNotifier<List<Booking>> bookings =
  ValueNotifier<List<Booking>>([]);

  static void add(Booking booking) {
    bookings.value = [booking, ...bookings.value];
  }
}