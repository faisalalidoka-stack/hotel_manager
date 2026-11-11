import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import '../utils/format.dart';
import 'static_data.dart';

// An error with a message that is safe to show to the user
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

String hashPassword(String password) =>
    sha256.convert(utf8.encode(password)).toString();

// ORDER BY clauses are looked up here, never built from user text
const Map<String, String> _roomOrder = {
  'Recommended': 'id ASC',
  'Price: low to high': 'price_per_night ASC',
  'Price: high to low': 'price_per_night DESC',
  'Top rated': 'rating DESC',
  'Name (A-Z)': 'name COLLATE NOCASE ASC',
};

const Map<String, String> _bookingOrder = {
  'Newest first': 'b.id DESC',
  'Check-in date': 'b.check_in ASC',
  'Highest value': 'b.total DESC',
};

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database>? _opening;

  // Screens listen to this and reload whenever data is written
  final ValueNotifier<int> revision = ValueNotifier<int>(0);
  void _changed() => revision.value++;

  Future<Database> get database => _opening ??= _open();

  Future<void> init({bool retry = false}) async {
    if (retry) _opening = null;
    await database;
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'pearl_suites.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _seed(db);
      },
    );
  }

  // ---------------------------------------------------------------
  // Tables
  // ---------------------------------------------------------------
  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('guest', 'admin'))
      )
    ''');

    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        bed TEXT NOT NULL,
        image_path TEXT NOT NULL,
        price_per_night INTEGER NOT NULL CHECK (price_per_night > 0),
        size_sqm INTEGER NOT NULL CHECK (size_sqm > 0),
        capacity INTEGER NOT NULL CHECK (capacity > 0),
        rating REAL NOT NULL DEFAULT 0,
        reviews INTEGER NOT NULL DEFAULT 0,
        facilities TEXT NOT NULL DEFAULT '',
        featured INTEGER NOT NULL DEFAULT 0,
        available INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL UNIQUE,
        user_id INTEGER NOT NULL,
        room_id INTEGER NOT NULL,
        check_in TEXT NOT NULL,
        check_out TEXT NOT NULL,
        guests INTEGER NOT NULL CHECK (guests > 0),
        guest_name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        payment TEXT NOT NULL,
        requests TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'Pending',
        total INTEGER NOT NULL CHECK (total >= 0),
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE RESTRICT
      )
    ''');
  }

  // Sample data so the app has something to show on first run
  Future<void> _seed(Database db) async {
    Future<int> addUser(
        String name, String email, String phone, String pass, String role) {
      return db.insert('users', {
        'full_name': name,
        'email': email,
        'phone': phone,
        'password_hash': hashPassword(pass),
        'role': role,
      });
    }

    await addUser('Hotel Manager', 'admin@pearlsuites.com', '0414 000 000',
        'admin123', 'admin');
    final guestId = await addUser('Ntege Fahim', 'ntege.fahim@gmail.com',
        '0757 686 831', 'guest123', 'guest');
    final guest2Id = await addUser('Amina Nakato', 'amina.nakato@gmail.com',
        '0772 345 678', 'guest123', 'guest');

    final roomIds = <int>[];
    for (final r in seedRooms) {
      roomIds.add(await db.insert('rooms', r.toMap()));
    }

    final today = dateOnly(DateTime.now());
    var n = 10000;

    Future<void> addBooking({
      required int userId,
      required String name,
      required String email,
      required String phone,
      required int roomIndex,
      required int startOffset,
      required int nights,
      required String status,
      required String payment,
    }) async {
      final checkIn = today.add(Duration(days: startOffset));
      final checkOut = checkIn.add(Duration(days: nights));
      await db.insert('bookings', {
        'reference': 'PSK-${n++}',
        'user_id': userId,
        'room_id': roomIds[roomIndex],
        'check_in': toDbDate(checkIn),
        'check_out': toDbDate(checkOut),
        'guests': 2,
        'guest_name': name,
        'email': email,
        'phone': phone,
        'payment': payment,
        'requests': '',
        'status': status,
        'total': nights * seedRooms[roomIndex].pricePerNight,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    const g1 = ['Ntege Fahim', 'ntege.fahim@gmail.com', '0757 686 831'];
    const g2 = ['Amina Nakato', 'amina.nakato@gmail.com', '0772 345 678'];

    await addBooking(userId: guestId, name: g1[0], email: g1[1], phone: g1[2],
        roomIndex: 2, startOffset: -240, nights: 2,
        status: 'Completed', payment: 'Card');
    await addBooking(userId: guestId, name: g1[0], email: g1[1], phone: g1[2],
        roomIndex: 3, startOffset: -90, nights: 2,
        status: 'Completed', payment: 'Mobile Money');
    await addBooking(userId: guestId, name: g1[0], email: g1[1], phone: g1[2],
        roomIndex: 0, startOffset: 14, nights: 3,
        status: 'Confirmed', payment: 'Pay at hotel');
    await addBooking(userId: guest2Id, name: g2[0], email: g2[1], phone: g2[2],
        roomIndex: 5, startOffset: 7, nights: 2,
        status: 'Pending', payment: 'Card');
    await addBooking(userId: guest2Id, name: g2[0], email: g2[1], phone: g2[2],
        roomIndex: 1, startOffset: -30, nights: 1,
        status: 'Completed', payment: 'Mobile Money');
    await addBooking(userId: guest2Id, name: g2[0], email: g2[1], phone: g2[2],
        roomIndex: 2, startOffset: 20, nights: 2,
        status: 'Cancelled', payment: 'Card');
  }

  // ---------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------
  void _validateContact(String name, String email, String phone) {
    if (name.trim().length < 3) {
      throw AppException('Please enter your full name.');
    }
    final e = email.trim();
    if (!e.contains('@') || !e.contains('.') || e.length < 6) {
      throw AppException('Enter a valid email address.');
    }
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) {
      throw AppException('Enter a valid phone number.');
    }
  }

  void _validateStay(Room room, DateTime checkIn, DateTime checkOut, int guests) {
    final today = dateOnly(DateTime.now());
    final inDate = dateOnly(checkIn);
    final outDate = dateOnly(checkOut);
    if (inDate.isBefore(today)) {
      throw AppException('Check-in date cannot be in the past.');
    }
    final nights = outDate.difference(inDate).inDays;
    if (nights < 1) {
      throw AppException('Check-out must be at least one night after check-in.');
    }
    if (nights > 30) {
      throw AppException('You can book a maximum of 30 nights at a time.');
    }
    if (guests < 1 || guests > room.capacity) {
      throw AppException('This room sleeps up to ${room.capacity} guests.');
    }
  }

  // Makes sure no other active booking overlaps the requested dates
  Future<void> _ensureRoomFree(
    Database db,
    int roomId,
    DateTime checkIn,
    DateTime checkOut, {
    int? excludeBookingId,
  }) async {
    final rows = await db.rawQuery(
      "SELECT COUNT(*) FROM bookings "
      "WHERE room_id = ? AND status IN ('Pending', 'Confirmed') "
      "AND check_in < ? AND check_out > ? "
      "${excludeBookingId != null ? 'AND id != ?' : ''}",
      [
        roomId,
        toDbDate(checkOut),
        toDbDate(checkIn),
        if (excludeBookingId != null) excludeBookingId,
      ],
    );
    if ((Sqflite.firstIntValue(rows) ?? 0) > 0) {
      throw AppException(
          'This room is already booked for those dates. Please choose different dates.');
    }
  }

  // ---------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------
  Future<AppUser> login(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password_hash = ?',
      whereArgs: [email.trim().toLowerCase(), hashPassword(password)],
    );
    if (rows.isEmpty) {
      throw AppException('Incorrect email or password.');
    }
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _validateContact(fullName, email, phone);
    if (password.length < 6) {
      throw AppException('Password must be at least 6 characters.');
    }
    final db = await database;
    final existing = await db.query('users',
        where: 'LOWER(email) = ?', whereArgs: [email.trim().toLowerCase()]);
    if (existing.isNotEmpty) {
      throw AppException('An account with this email already exists.');
    }
    final id = await db.insert('users', {
      'full_name': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password_hash': hashPassword(password),
      'role': 'guest',
    });
    _changed();
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser> updateUser({
    required int id,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    _validateContact(fullName, email, phone);
    final db = await database;
    final clash = await db.query('users',
        where: 'LOWER(email) = ? AND id != ?',
        whereArgs: [email.trim().toLowerCase(), id]);
    if (clash.isNotEmpty) {
      throw AppException('Another account already uses this email.');
    }
    await db.update(
      'users',
      {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _changed();
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return AppUser.fromMap(rows.first);
  }

  // Admin: list guests with how many bookings each one has
  Future<List<AppUser>> getGuests({String search = ''}) async {
    final db = await database;
    final q = '%${search.trim()}%';
    final rows = await db.rawQuery(
      "SELECT u.*, (SELECT COUNT(*) FROM bookings b WHERE b.user_id = u.id) "
      "AS booking_count FROM users u WHERE u.role = 'guest' "
      "${search.trim().isEmpty ? '' : 'AND (u.full_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)'} "
      "ORDER BY u.full_name COLLATE NOCASE ASC",
      search.trim().isEmpty ? [] : [q, q, q],
    );
    return rows.map(AppUser.fromMap).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    final count = await db.delete('users',
        where: "id = ? AND role = 'guest'", whereArgs: [id]);
    if (count == 0) throw AppException('This guest no longer exists.');
    _changed();
  }

  // ---------------------------------------------------------------
  // Rooms
  // ---------------------------------------------------------------
  Future<List<Room>> getRooms({
    String search = '',
    String type = 'All',
    String sort = 'Recommended',
    bool onlyAvailable = true,
    bool featuredOnly = false,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];
    if (onlyAvailable) where.add('available = 1');
    if (featuredOnly) where.add('featured = 1');
    if (type != 'All') {
      where.add('type = ?');
      args.add(type);
    }
    if (search.trim().isNotEmpty) {
      where.add('(name LIKE ? OR description LIKE ? OR type LIKE ?)');
      final q = '%${search.trim()}%';
      args.addAll([q, q, q]);
    }
    final rows = await db.query(
      'rooms',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: _roomOrder[sort] ?? 'id ASC',
    );
    return rows.map(Room.fromMap).toList();
  }

  Future<Room?> getRoom(int id) async {
    final db = await database;
    final rows = await db.query('rooms', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Room.fromMap(rows.first);
  }

  void _validateRoom(Room r) {
    if (r.name.trim().length < 3) {
      throw AppException('Room name must be at least 3 characters.');
    }
    if (r.pricePerNight <= 0) {
      throw AppException('Price must be greater than zero.');
    }
    if (r.sizeSqm <= 0) throw AppException('Room size must be greater than zero.');
    if (r.capacity < 1 || r.capacity > 10) {
      throw AppException('Capacity must be between 1 and 10 guests.');
    }
    if (r.description.trim().length < 10) {
      throw AppException('Please write a short description (10+ characters).');
    }
  }

  Future<void> _ensureRoomNameFree(Database db, String name, {int? exceptId}) async {
    final rows = await db.query('rooms',
        where: 'LOWER(name) = ? AND id != ?',
        whereArgs: [name.trim().toLowerCase(), exceptId ?? -1]);
    if (rows.isNotEmpty) {
      throw AppException('A room with this name already exists.');
    }
  }

  Future<void> insertRoom(Room room) async {
    _validateRoom(room);
    final db = await database;
    await _ensureRoomNameFree(db, room.name);
    final map = room.toMap()..remove('id');
    await db.insert('rooms', map);
    _changed();
  }

  Future<void> updateRoom(Room room) async {
    _validateRoom(room);
    final db = await database;
    await _ensureRoomNameFree(db, room.name, exceptId: room.id);
    await db.update('rooms', room.toMap(), where: 'id = ?', whereArgs: [room.id]);
    _changed();
  }

  Future<void> setRoomAvailable(int id, bool available) async {
    final db = await database;
    await db.update('rooms', {'available': available ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
    _changed();
  }

  Future<void> deleteRoom(int id) async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT COUNT(*) FROM bookings WHERE room_id = ?', [id]);
    final count = Sqflite.firstIntValue(rows) ?? 0;
    if (count > 0) {
      throw AppException(
          'This room has $count booking(s) and cannot be deleted. Hide it instead.');
    }
    await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
    _changed();
  }

  // ---------------------------------------------------------------
  // Bookings
  // ---------------------------------------------------------------
  Future<List<Booking>> getBookings({
    int? userId,
    String status = 'All',
    String search = '',
    String sort = 'Newest first',
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];
    if (userId != null) {
      where.add('b.user_id = ?');
      args.add(userId);
    }
    if (status != 'All') {
      where.add('b.status = ?');
      args.add(status);
    }
    if (search.trim().isNotEmpty) {
      where.add(
          '(b.reference LIKE ? OR b.guest_name LIKE ? OR r.name LIKE ?)');
      final q = '%${search.trim()}%';
      args.addAll([q, q, q]);
    }
    final rows = await db.rawQuery(
      'SELECT b.* FROM bookings b JOIN rooms r ON r.id = b.room_id '
      '${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'} '
      'ORDER BY ${_bookingOrder[sort] ?? 'b.id DESC'}',
      args,
    );

    final roomRows = await db.query('rooms');
    final roomMap = {for (final r in roomRows) r['id'] as int: Room.fromMap(r)};
    return rows
        .map((m) => Booking.fromMap(m, roomMap[m['room_id'] as int]!))
        .toList();
  }

  Future<Booking> createBooking({
    required AppUser user,
    required Room room,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String guestName,
    required String email,
    required String phone,
    required String payment,
    required String requests,
  }) async {
    final db = await database;
    final fresh = await getRoom(room.id!);
    if (fresh == null || !fresh.available) {
      throw AppException('This room is no longer available.');
    }
    _validateContact(guestName, email, phone);
    _validateStay(fresh, checkIn, checkOut, guests);
    await _ensureRoomFree(db, fresh.id!, checkIn, checkOut);

    final nights = dateOnly(checkOut).difference(dateOnly(checkIn)).inDays;
    final reference = 'PSK-${Random().nextInt(900000) + 100000}';
    final values = {
      'reference': reference,
      'user_id': user.id,
      'room_id': fresh.id,
      'check_in': toDbDate(checkIn),
      'check_out': toDbDate(checkOut),
      'guests': guests,
      'guest_name': guestName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'payment': payment,
      'requests': requests.trim(),
      'status': 'Pending',
      'total': nights * fresh.pricePerNight,
      'created_at': DateTime.now().toIso8601String(),
    };
    final id = await db.insert('bookings', values);
    _changed();
    return Booking.fromMap({...values, 'id': id}, fresh);
  }

  Future<void> updateBookingDetails({
    required int id,
    required Room room,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String guestName,
    required String email,
    required String phone,
    required String payment,
    required String requests,
  }) async {
    final db = await database;
    final fresh = await getRoom(room.id!);
    if (fresh == null) throw AppException('This room no longer exists.');
    _validateContact(guestName, email, phone);
    _validateStay(fresh, checkIn, checkOut, guests);
    await _ensureRoomFree(db, fresh.id!, checkIn, checkOut,
        excludeBookingId: id);

    final nights = dateOnly(checkOut).difference(dateOnly(checkIn)).inDays;
    final count = await db.update(
      'bookings',
      {
        'check_in': toDbDate(checkIn),
        'check_out': toDbDate(checkOut),
        'guests': guests,
        'guest_name': guestName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'payment': payment,
        'requests': requests.trim(),
        'total': nights * fresh.pricePerNight,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count == 0) throw AppException('This booking no longer exists.');
    _changed();
  }

  Future<void> updateBookingStatus(int id, String status) async {
    if (!bookingStatuses.contains(status)) {
      throw AppException('Unknown booking status.');
    }
    final db = await database;
    await db.update('bookings', {'status': status},
        where: 'id = ?', whereArgs: [id]);
    _changed();
  }

  Future<void> deleteBooking(int id) async {
    final db = await database;
    await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
    _changed();
  }

  // ---------------------------------------------------------------
  // Reports (all figures come from SQL queries on saved records)
  // ---------------------------------------------------------------
  Future<BookingSummary> bookingSummary({int? userId}) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT status, COUNT(*) AS c, COALESCE(SUM(total), 0) AS v '
      'FROM bookings ${userId != null ? 'WHERE user_id = ?' : ''} '
      'GROUP BY status',
      userId != null ? [userId] : [],
    );
    final counts = <String, int>{};
    var value = 0;
    for (final r in rows) {
      final status = r['status'] as String;
      counts[status] = r['c'] as int;
      if (status != 'Cancelled') value += r['v'] as int;
    }
    return BookingSummary(countByStatus: counts, totalValue: value);
  }

  Future<DashboardData> dashboard() async {
    final db = await database;
    final summary = await bookingSummary();
    final roomCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM rooms')) ??
        0;
    final guestCount = Sqflite.firstIntValue(await db
            .rawQuery("SELECT COUNT(*) FROM users WHERE role = 'guest'")) ??
        0;
    final rows = await db.rawQuery(
      'SELECT r.type AS type, COUNT(b.id) AS bookings, '
      'COALESCE(SUM(b.total), 0) AS revenue '
      'FROM rooms r LEFT JOIN bookings b '
      "ON b.room_id = r.id AND b.status != 'Cancelled' "
      'GROUP BY r.type ORDER BY revenue DESC',
    );
    return DashboardData(
      summary: summary,
      roomCount: roomCount,
      guestCount: guestCount,
      revenueByType: rows
          .map((r) => RevenueRow(
              r['type'] as String, r['bookings'] as int, r['revenue'] as int))
          .toList(),
    );
  }
}
