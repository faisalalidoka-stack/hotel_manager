import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'admin_shell.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user =
          await DatabaseHelper.instance.login(_emailCtrl.text, _passCtrl.text);
      Session.user = user;
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => user.isAdmin ? const AdminShell() : const MainShell(),
        ),
        (route) => false,
      );
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not reach the database. Please restart the app.',
            error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(String email, String password) {
    setState(() {
      _emailCtrl.text = email;
      _passCtrl.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: const SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    SizedBox(height: 28),
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.accent,
                      child: Icon(Icons.hotel, color: Colors.white, size: 36),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Pearl Suites Kampala',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sign in to book your stay',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Enter your email';
                        if (!t.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter your password'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text("New here? Create an account"),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Demo accounts for testing both user types
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demo accounts (tap to fill)',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.person, size: 18),
                                label: const Text('Guest'),
                                onPressed: () =>
                                    _fill('ntege.fahim@gmail.com', 'guest123'),
                              ),
                              ActionChip(
                                avatar: const Icon(
                                    Icons.admin_panel_settings,
                                    size: 18),
                                label: const Text('Admin'),
                                onPressed: () =>
                                    _fill('admin@pearlsuites.com', 'admin123'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
