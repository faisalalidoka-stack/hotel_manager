import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'admin_bookings_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_guests_screen.dart';
import 'admin_rooms_screen.dart';

// Main screen for the hotel manager (admin user type)
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminDashboardScreen(onNavigate: _go),
      const AdminRoomsScreen(),
      const AdminBookingsScreen(),
      const AdminGuestsScreen(),
    ];
  }

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _go,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bed_outlined),
              activeIcon: Icon(Icons.bed),
              label: 'Rooms'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Guests'),
        ],
      ),
    );
  }
}
