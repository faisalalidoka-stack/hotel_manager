import 'package:flutter/material.dart';
import '../models/models.dart';

// Static lists used for filters, forms and first-run sample data.
// Rooms, users and bookings themselves now live in the SQLite database.

const List<String> roomTypes = [
  'All',
  'Standard',
  'Deluxe',
  'Executive',
  'Family',
  'Suite',
];

// Same list without 'All' - used in the admin room form
const List<String> roomTypeChoices = [
  'Standard',
  'Deluxe',
  'Executive',
  'Family',
  'Suite',
];

const List<String> bookingStatuses = [
  'Pending',
  'Confirmed',
  'Completed',
  'Cancelled',
];

const List<String> paymentOptions = ['Pay at hotel', 'Mobile Money', 'Card'];

const List<String> roomSortOptions = [
  'Recommended',
  'Price: low to high',
  'Price: high to low',
  'Top rated',
  'Name (A-Z)',
];

const List<String> bookingSortOptions = [
  'Newest first',
  'Check-in date',
  'Highest value',
];

// Photos that can be chosen in the admin room form
const List<String> roomImages = [
  'assets/images/standard_queen.jpg',
  'assets/images/standard_twin.jpg',
  'assets/images/deluxe_garden.jpg',
  'assets/images/executive_lake.jpg',
  'assets/images/family_suite.jpg',
  'assets/images/presidential.jpg',
];

// Hotel services shown on home screen
const List<HotelService> services = [
  HotelService('Airport Pickup', 'UGX 120,000', Icons.airport_shuttle),
  HotelService('Pearl Terrace', 'Breakfast UGX 45,000', Icons.restaurant),
  HotelService('Spa and Massage', 'From UGX 90,000', Icons.spa),
  HotelService('Conference Hall', 'UGX 800,000 / day', Icons.business_center),
  HotelService('Laundry', 'From UGX 15,000', Icons.local_laundry_service),
  HotelService('City Tour', 'UGX 250,000', Icons.map),
];

// Sample rooms inserted the first time the database is created
const List<Room> seedRooms = [
  Room(
    name: 'Standard Queen Room',
    type: 'Standard',
    description:
        'A bright, comfortable room with a plush queen bed and a calm garden outlook. '
        'Ideal for solo travellers and couples visiting Kampala for business or a short getaway.',
    bed: '1 Queen bed',
    imagePath: 'assets/images/standard_queen.jpg',
    pricePerNight: 180000,
    sizeSqm: 22,
    capacity: 2,
    rating: 4.5,
    reviews: 128,
    facilityKeys: ['wifi', 'ac', 'tv', 'shower', 'coffee', 'parking'],
  ),
  Room(
    name: 'Standard Twin Room',
    type: 'Standard',
    description:
        'Two single beds, a workspace and a modern en-suite bathroom. '
        'A practical choice for colleagues or friends travelling together.',
    bed: '2 Single beds',
    imagePath: 'assets/images/standard_twin.jpg',
    pricePerNight: 190000,
    sizeSqm: 24,
    capacity: 2,
    rating: 4.4,
    reviews: 96,
    facilityKeys: ['wifi', 'ac', 'tv', 'desk', 'shower', 'parking'],
  ),
  Room(
    name: 'Deluxe Garden View',
    type: 'Deluxe',
    description:
        'A spacious king room overlooking our tropical gardens, with a sitting corner, '
        'rain shower and complimentary breakfast served at the Pearl Terrace restaurant.',
    bed: '1 King bed',
    imagePath: 'assets/images/deluxe_garden.jpg',
    pricePerNight: 280000,
    sizeSqm: 30,
    capacity: 2,
    rating: 4.7,
    reviews: 214,
    facilityKeys: [
      'wifi', 'ac', 'tv', 'breakfast', 'minibar', 'safe', 'shower', 'pool',
    ],
    featured: true,
  ),
  Room(
    name: 'Executive Lake View',
    type: 'Executive',
    description:
        'Wake up to sweeping views toward Lake Victoria from your private balcony. '
        'Includes a dedicated work desk, premium bedding, lounge access and breakfast.',
    bed: '1 King bed',
    imagePath: 'assets/images/executive_lake.jpg',
    pricePerNight: 420000,
    sizeSqm: 38,
    capacity: 3,
    rating: 4.8,
    reviews: 173,
    facilityKeys: [
      'wifi', 'ac', 'tv', 'balcony', 'desk', 'breakfast', 'minibar', 'safe',
      'bath', 'pool',
    ],
    featured: true,
  ),
  Room(
    name: 'Family Suite',
    type: 'Family',
    description:
        'Two bedrooms with a shared living area and kitchenette, designed for families. '
        'Children stay free and extra beds are available on request.',
    bed: '2 Queen beds',
    imagePath: 'assets/images/family_suite.jpg',
    pricePerNight: 520000,
    sizeSqm: 55,
    capacity: 4,
    rating: 4.6,
    reviews: 89,
    facilityKeys: [
      'wifi', 'ac', 'tv', 'kitchen', 'breakfast', 'safe', 'shower', 'parking',
      'pool',
    ],
    featured: true,
  ),
  Room(
    name: 'Presidential Suite',
    type: 'Suite',
    description:
        'Our signature suite on the top floor with a separate lounge, dining area, '
        'private jacuzzi terrace and a dedicated butler. Airport pickup is included.',
    bed: '1 Super King bed',
    imagePath: 'assets/images/presidential.jpg',
    pricePerNight: 1200000,
    sizeSqm: 90,
    capacity: 4,
    rating: 4.9,
    reviews: 41,
    facilityKeys: [
      'wifi', 'ac', 'tv', 'jacuzzi', 'balcony', 'service', 'breakfast',
      'minibar', 'safe', 'coffee', 'parking', 'pool',
    ],
    featured: true,
  ),
];
