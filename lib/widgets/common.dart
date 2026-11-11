import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/session.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

// Shows the room photo if the asset exists, otherwise shows a colored gradient
class RoomImage extends StatelessWidget {
  final Room room;
  final double height;
  const RoomImage({super.key, required this.room, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        room.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          // If image not found, show a gradient with an icon instead
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: room.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(room.icon, size: 56, color: Colors.white54),
            ),
          );
        },
      ),
    );
  }
}

// Shows the price with a /night suffix
class PriceText extends StatelessWidget {
  final int amount;
  final double size;
  final bool showSuffix;
  const PriceText({
    super.key,
    required this.amount,
    this.size = 16,
    this.showSuffix = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: formatUgx(amount),
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        children: [
          if (showSuffix)
            const TextSpan(
              text: ' /night',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

// A section title row with optional "see all" button
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------------
// Shared helpers for messages, dialogs and screen states
// ---------------------------------------------------------------

// Shows a success or error snack bar
void showMessage(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red.shade700 : AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// Asks the user to confirm before a destructive action
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

// Runs a database action and shows a success or error message
Future<bool> runDb(
  BuildContext context,
  Future<void> Function() action, {
  required String success,
}) async {
  try {
    await action();
    if (context.mounted) showMessage(context, success);
    return true;
  } on AppException catch (e) {
    if (context.mounted) showMessage(context, e.message, error: true);
  } catch (_) {
    if (context.mounted) {
      showMessage(
        context,
        'Something went wrong with the database. Please try again.',
        error: true,
      );
    }
  }
  return false;
}

// Logs out and returns to the login screen
Future<void> signOut(BuildContext context) async {
  final ok = await confirmDialog(
    context,
    title: 'Sign out?',
    message: 'You can sign back in at any time.',
    confirmLabel: 'Sign out',
  );
  if (!ok || !context.mounted) return;
  Session.user = null;
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Coloured label for a booking status
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  static Color colorFor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF2E9E6B);
      case 'Completed':
        return AppColors.primary;
      case 'Cancelled':
        return Colors.red.shade600;
      default:
        return AppColors.accent; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Search box used on several screens
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// Row of selectable filter chips
class FilterChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final option = options[i];
          final isSelected = option == selected;
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
            onSelected: (_) => onSelected(option),
          );
        },
      ),
    );
  }
}

// Small "sort by" menu
class SortMenu extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;
  const SortMenu({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (_) => options
          .map((o) => PopupMenuItem<String>(
                value: o,
                child: Text(
                  o,
                  style: TextStyle(
                    fontWeight: o == value ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort, size: 18, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
