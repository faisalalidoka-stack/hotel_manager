import 'package:flutter/material.dart';
import '../data/booking_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  const BookingScreen({super.key, required this.room});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _requestsCtrl = TextEditingController();

  late DateTime _checkIn;
  late DateTime _checkOut;
  int _guests = 1;
  String _payment = 'Pay at hotel';

  static const _paymentOptions = ['Pay at hotel', 'Mobile Money', 'Card'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _checkIn = DateTime(now.year, now.month, now.day + 1);
    _checkOut = DateTime(now.year, now.month, now.day + 3);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _requestsCtrl.dispose();
    super.dispose();
  }

  int get _nights => _checkOut.difference(_checkIn).inDays;
  int get _total => _nights * widget.room.pricePerNight;

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
      if (!_checkOut.isAfter(_checkIn)) {
        _checkOut = _checkIn.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickCheckOut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: _checkIn.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _checkOut = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final ref = 'PSK-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}';
    final booking = Booking(
      reference: ref,
      room: widget.room,
      checkIn: _checkIn,
      checkOut: _checkOut,
      guests: _guests,
      guestName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      payment: _payment,
      requests: _requestsCtrl.text.trim(),
    );
    BookingStore.add(booking);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ConfirmationScreen(booking: booking)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Scaffold(
      appBar: AppBar(title: const Text('Book your stay')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Room summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
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
                        Text(room.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(
                          '${formatUgx(room.pricePerNight)} per night',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _Heading('Stay details'),
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
                  IconButton(
                    onPressed:
                    _guests > 1 ? () => setState(() => _guests--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_guests',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
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
            const _Heading('Guest information'),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Please enter your full name'
                  : null,
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
                final t = v?.trim() ?? '';
                if (!t.contains('@') || !t.contains('.')) {
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
                return digits.length < 9 ? 'Enter a valid phone number' : null;
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
            const _Heading('Payment method'),
            Wrap(
              spacing: 8,
              children: _paymentOptions.map((p) {
                final selected = p == _payment;
                return ChoiceChip(
                  label: Text(p),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _payment = p),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            const Text(
              "You won't be charged now.",
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _PriceRow(
                    '${formatUgx(room.pricePerNight)} × $_nights ${_nights == 1 ? 'night' : 'nights'}',
                    formatUgx(_total),
                  ),
                  const SizedBox(height: 8),
                  const _PriceRow('Taxes & service fee', 'Included'),
                  const Divider(height: 24),
                  _PriceRow('Total', formatUgx(_total), bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Confirm booking'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  const _DateField(
      {required this.label, required this.value, required this.onTap});

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
        child: Text(formatDate(value),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;
  const _PriceRow(this.left, this.right, {this.bold = false});

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