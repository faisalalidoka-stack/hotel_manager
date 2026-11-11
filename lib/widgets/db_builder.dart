import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import 'common.dart';

// Loads data from the database and shows loading and error states.
// It reloads by itself whenever any screen writes to the database,
// so every screen always shows up-to-date records.
class DbBuilder<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  const DbBuilder({super.key, required this.load, required this.builder});

  @override
  State<DbBuilder<T>> createState() => _DbBuilderState<T>();
}

class _DbBuilderState<T> extends State<DbBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
    DatabaseHelper.instance.revision.addListener(_reload);
  }

  @override
  void didUpdateWidget(covariant DbBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent rebuilt (for example the search text changed)
    _future = widget.load();
  }

  @override
  void dispose() {
    DatabaseHelper.instance.revision.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = widget.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Could not load data from the database.',
            onRetry: _reload,
          );
        }
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data as T);
        }
        return const LoadingView();
      },
    );
  }
}
