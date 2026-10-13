import 'package:flutter/material.dart';
import '../models/models.dart';

const _wifi = Facility('Free Wi-Fi', Icons.wifi);
const _ac = Facility('Air conditioning', Icons.ac_unit);
const _tv = Facility('Smart TV', Icons.tv);
const _shower = Facility('Hot shower', Icons.shower);
const _coffee = Facility('Tea & coffee', Icons.coffee);
const _breakfast = Facility('Breakfast included', Icons.free_breakfast);
const _desk = Facility('Work desk', Icons.desk);
const _safe = Facility('In-room safe', Icons.lock);
const _minibar = Facility('Mini bar', Icons.local_bar);
const _balcony = Facility('Private balcony', Icons.balcony);
const _bath = Facility('Bathtub', Icons.bathtub);
const _jacuzzi = Facility('Jacuzzi', Icons.hot_tub);
const _parking = Facility('Free parking', Icons.local_parking);
const _pool = Facility('Pool access', Icons.pool);
const _kitchen = Facility('Kitchenette', Icons.kitchen);
const _service = Facility('24h room service', Icons.room_service);

const String guestName = 'Sarah Namuli';
const String guestEmail = 'sarah.namuli@gmail.com';
const String guestPhone = '0772 123 456';

const List<Room> rooms = [
  Room(
    id: 1,
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
    facilities: [_wifi, _ac, _tv, _shower, _coffee, _parking],
    gradient: [Color(0xFF2E7D6F), Color(0xFF0F4C45)],
    icon: Icons.bed,
  ),
  Room(
    id: 2,
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
    facilities: [_wifi, _ac, _tv, _desk, _shower, _parking],
    gradient: [Color(0xFF3B8F80), Color(0xFF145A52)],
    icon: Icons.single_bed,
  ),
  Room(
    id: 3,
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
    facilities: [_wifi, _ac, _tv, _breakfast, _minibar, _safe, _shower, _pool],
    gradient: [Color(0xFF4C8F5A), Color(0xFF1F5B3A)],
    icon: Icons.king_bed,
    featured: true,
  ),
  Room(
    id: 4,
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
    facilities: [
      _wifi, _ac, _tv, _balcony, _desk, _breakfast, _minibar, _safe, _bath, _pool
    ],
    gradient: [Color(0xFF1E6F8C), Color(0xFF0F3F5A)],
    icon: Icons.king_bed,
    featured: true,
  ),
  Room(
    id: 5,
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
    facilities: [
      _wifi, _ac, _tv, _kitchen, _breakfast, _safe, _shower, _parking, _pool
    ],
    gradient: [Color(0xFFB07A3A), Color(0xFF6B4620)],
    icon: Icons.family_restroom,
    featured: true,
  ),
  Room(
    id: 6,
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
    facilities: [
      _wifi, _ac, _tv, _jacuzzi, _balcony, _service, _breakfast, _minibar,
      _safe, _coffee, _parking, _pool
    ],
    gradient: [Color(0xFFC9A24B), Color(0xFF7A5A1A)],
    icon: Icons.workspace_premium,
    featured: true,
  ),
];

const List<String> roomTypes = [
  'All', 'Standard', 'Deluxe', 'Executive', 'Family', 'Suite'
];

const List<HotelService> services = [
  HotelService('Airport pickup', 'UGX 120,000', Icons.airport_shuttle),
  HotelService('Pearl Terrace', 'Breakfast UGX 45,000', Icons.restaurant),
  HotelService('Spa & massage', 'From UGX 90,000', Icons.spa),
  HotelService('Conference hall', 'UGX 800,000 / day', Icons.business_center),
  HotelService('Laundry', 'From UGX 15,000', Icons.local_laundry_service),
  HotelService('City & Nile tour', 'UGX 250,000', Icons.map),
];