import 'package:flutter/material.dart';

class Facility {
  final String label;
  final IconData icon;
  const Facility(this.label, this.icon);
}

class Room {
  final int id;
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
  final List<Facility> facilities;
  final List<Color> gradient;
  final IconData icon;
  final bool featured;

  const Room({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.bed,
    required this.imagePath,
    required this.pricePerNight,
    required this.sizeSqm,
    required this.capacity,
    required this.rating,
    required this.reviews,
    required this.facilities,
    required this.gradient,
    required this.icon,
    this.featured = false,
  });
}

class HotelService {
  final String title;
  final String price;
  final IconData icon;
  const HotelService(this.title, this.price, this.icon);
}

class Booking {
  final String reference;
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String guestName;
  final String email;
  final String phone;
  final String payment;
  final String requests;

  const Booking({
    required this.reference,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.guestName,
    required this.email,
    required this.phone,
    required this.payment,
    required this.requests,
  });

  int get nights => checkOut.difference(checkIn).inDays;
  int get total => nights * room.pricePerNight;
}