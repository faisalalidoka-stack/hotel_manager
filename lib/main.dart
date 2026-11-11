import 'package:flutter/material.dart';
import 'data/database_helper.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PearlSuitesApp());
}

class PearlSuitesApp extends StatelessWidget {
  const PearlSuitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pearl Suites Kampala',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const StartupGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

// Opens the database before showing the first screen
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late Future<void> _init = DatabaseHelper.instance.init();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: ErrorView(
              message: 'The database could not be opened.',
              onRetry: () => setState(() {
                _init = DatabaseHelper.instance.init(retry: true);
              }),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const LoginScreen();
        }
        return const Scaffold(body: LoadingView());
      },
    );
  }
}
