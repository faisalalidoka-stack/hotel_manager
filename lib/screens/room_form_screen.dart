import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/static_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

// Admin form to add a new room or edit an existing one
class RoomFormScreen extends StatefulWidget {
  final Room? room; // null = add a new room
  const RoomFormScreen({super.key, this.room});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _bedCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _type = roomTypeChoices.first;
  String? _image; // null = no photo (a coloured tile is shown instead)
  final Set<String> _facilities = {};
  bool _featured = false;
  bool _available = true;
  bool _saving = false;

  bool get _isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    if (r != null) {
      _nameCtrl.text = r.name;
      _priceCtrl.text = '${r.pricePerNight}';
      _sizeCtrl.text = '${r.sizeSqm}';
      _capacityCtrl.text = '${r.capacity}';
      _bedCtrl.text = r.bed;
      _descCtrl.text = r.description;
      _type = r.type;
      _image = roomImages.contains(r.imagePath) ? r.imagePath : null;
      _facilities.addAll(r.facilityKeys);
      _featured = r.featured;
      _available = r.available;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _sizeCtrl.dispose();
    _capacityCtrl.dispose();
    _bedCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _positiveNumber(String? v, String label, {int? max}) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return 'Enter a valid number for $label';
    if (n <= 0) return '$label must be greater than zero';
    if (max != null && n > max) return '$label cannot be more than $max';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final old = widget.room;
    final room = Room(
      id: old?.id,
      name: _nameCtrl.text.trim(),
      type: _type,
      description: _descCtrl.text.trim(),
      bed: _bedCtrl.text.trim(),
      imagePath: _image ?? 'assets/images/none.jpg',
      pricePerNight: int.parse(_priceCtrl.text.trim()),
      sizeSqm: int.parse(_sizeCtrl.text.trim()),
      capacity: int.parse(_capacityCtrl.text.trim()),
      rating: old?.rating ?? 0,
      reviews: old?.reviews ?? 0,
      facilityKeys: facilityCatalog.keys.where(_facilities.contains).toList(),
      featured: _featured,
      available: _available,
    );

    final db = DatabaseHelper.instance;
    final ok = await runDb(
      context,
      () => _isEditing ? db.updateRoom(room) : db.insertRoom(room),
      success: _isEditing ? 'Room updated' : 'Room added',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit room' : 'Add room')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Room name',
                prefixIcon: Icon(Icons.bed_outlined),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Enter a room name (3+ characters)'
                  : null,
            ),

            _heading('Room type'),
            Wrap(
              spacing: 8,
              children: roomTypeChoices.map((t) {
                final selected = t == _type;
                return ChoiceChip(
                  label: Text(t),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _type = t),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price per night (UGX)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) =>
                  _positiveNumber(v, 'Price', max: 10000000),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Size (m²)'),
                    validator: (v) => _positiveNumber(v, 'Size', max: 500),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Guests'),
                    validator: (v) => _positiveNumber(v, 'Guests', max: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bedCtrl,
              decoration: const InputDecoration(
                labelText: 'Beds, e.g. 1 King bed',
                prefixIcon: Icon(Icons.king_bed_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Describe the beds'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Write a short description (10+ characters)'
                  : null,
            ),

            _heading('Photo'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('No photo'),
                  selected: _image == null,
                  onSelected: (_) => setState(() => _image = null),
                ),
                for (final path in roomImages)
                  ChoiceChip(
                    label: Text(path
                        .split('/')
                        .last
                        .replaceAll('.jpg', '')
                        .replaceAll('_', ' ')),
                    selected: _image == path,
                    onSelected: (_) => setState(() => _image = path),
                  ),
              ],
            ),

            _heading('Facilities'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: facilityCatalog.entries.map((e) {
                final on = _facilities.contains(e.key);
                return FilterChip(
                  avatar: Icon(e.value.icon, size: 16),
                  label: Text(e.value.label),
                  selected: on,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _facilities.add(e.key);
                    } else {
                      _facilities.remove(e.key);
                    }
                  }),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Featured on home screen'),
              value: _featured,
              onChanged: (v) => setState(() => _featured = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Available for booking'),
              subtitle: const Text('Turn off to hide this room from guests'),
              value: _available,
              onChanged: (v) => setState(() => _available = v),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Add room'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
