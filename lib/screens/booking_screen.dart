import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/session.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  final Booking? existing; // set when editing a saved booking
  const BookingScreen({super.key, required this.room, this.existing});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Form key to validate all fields together
  final _formKey = GlobalKey<FormState>();

  // Text controllers for each input field
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _requestsCtrl = TextEditingController();

  late DateTime _checkIn;
  late DateTime _checkOut;
  int _guests = 1;
  String _payment = 'Pay at hotel';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      // Editing: start with the saved booking values
      _checkIn = existing.checkIn;
      _checkOut = existing.checkOut;
      _guests = existing.guests;
      _payment = existing.payment;
      _nameCtrl.text = existing.guestName;
      _emailCtrl.text = existing.email;
      _phoneCtrl.text = existing.phone;
      _requestsCtrl.text = existing.requests;
    } else {
      // New booking: tomorrow check-in, 2 days later check-out
      final now = DateTime.now();
      _checkIn = DateTime(now.year, now.month, now.day + 1);
      _checkOut = DateTime(now.year, now.month, now.day + 3);
      // Fill the form from the logged in guest
      final user = Session.user;
      if (user != null) {
        _nameCtrl.text = user.fullName;
        _emailCtrl.text = user.email;
        _phoneCtrl.text = user.phone;
      }
    }
  }

  // Clean up controllers when widget is removed
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _requestsCtrl.dispose();
    super.dispose();
  }

  // How many nights between check-in and check-out
  int get _nights => _checkOut.difference(_checkIn).inDays;

  // Total price
  int get _total => _nights * widget.room.pricePerNight;

  // Open date picker for check-in
  Future<void> _pickCheckIn() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _checkIn = picked;
      // Make sure check-out is always after check-in
      if (!_checkOut.isAfter(_checkIn)) {
        _checkOut = _checkIn.add(const Duration(days: 1));
      }
    });
  }

  // Open date picker for check-out
  Future<void> _pickCheckOut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: _checkIn.add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _checkOut = picked;
      });
    }
  }

  // Validate, then save the booking in the database
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final db = DatabaseHelper.instance;
    try {
      final existing = widget.existing;
      if (existing == null) {
        // Create a new booking record
        final booking = await db.createBooking(
          user: Session.user!,
          room: widget.room,
          checkIn: _checkIn,
          checkOut: _checkOut,
          guests: _guests,
          guestName: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          payment: _payment,
          requests: _requestsCtrl.text,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmationScreen(booking: booking),
          ),
        );
      } else {
        // Update the existing booking record
        await db.updateBookingDetails(
          id: existing.id!,
          room: widget.room,
          checkIn: _checkIn,
          checkOut: _checkOut,
          guests: _guests,
          guestName: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          payment: _payment,
          requests: _requestsCtrl.text,
        );
        if (!mounted) return;
        showMessage(context, 'Booking updated');
        Navigator.pop(context);
      }
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not save the booking. Please try again.',
            error: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Book your stay' : 'Edit booking'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Room summary card at top
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Room icon preview
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: room.gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(room.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${formatUgx(room.pricePerNight)} per night',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Stay dates section
            const _SectionHeading('Stay Details'),

            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Check-in',
                    value: _checkIn,
                    onTap: _pickCheckIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Check-out',
                    value: _checkOut,
                    onTap: _pickCheckOut,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Guest count row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Guests (max ${room.capacity})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Minus button
                  IconButton(
                    onPressed: _guests > 1
                        ? () => setState(() => _guests--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_guests',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Plus button
                  IconButton(
                    onPressed: _guests < room.capacity
                        ? () => setState(() => _guests++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Guest info section
            const _SectionHeading('Guest Information'),

            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '07XX XXX XXX',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length < 9) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _requestsCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Special requests (optional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.edit_note),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Payment method section
            const _SectionHeading('Payment Method'),

            Wrap(
              spacing: 8,
              children: paymentOptions.map((option) {
                final isSelected = option == _payment;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() => _payment = option);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 6),

            const Text(
              'You will not be charged now.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),

            const SizedBox(height: 22),

            // Price summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _PriceLine(
                    '${formatUgx(room.pricePerNight)} x $_nights ${_nights == 1 ? 'night' : 'nights'}',
                    formatUgx(_total),
                  ),
                  const SizedBox(height: 8),
                  const _PriceLine('Taxes and service fee', 'Included'),
                  const Divider(height: 24),
                  _PriceLine('Total', formatUgx(_total), bold: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.existing == null
                      ? 'Confirm Booking'
                      : 'Save Changes'),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// Section heading text
class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Tappable date field
class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          formatDate(value),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// A single price row in the summary
class _PriceLine extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;
  const _PriceLine(this.left, this.right, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
      color: bold ? AppColors.primary : AppColors.text,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(left, style: style)),
        const SizedBox(width: 8),
        Text(right, style: style),
      ],
    );
  }
}
