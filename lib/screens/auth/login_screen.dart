import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../student/student_home.dart';
import '../staff/staff_home.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  void _login() async {
    final authService = context.read<AuthService>();
    final success = await authService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      final user = authService.currentUser;
      if (user?.role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentHome()),
        );
      } else if (user?.role == 'staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StaffHome()),
        );
      } else if (user?.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid email or password. Use student@example.com, staff@example.com, or admin@example.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.apartment,
                  size: 80,
                  color: Color(0xFF4F46E5), // Using primary color
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to HostelMate',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your hostel life seamlessly',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: context.watch<AuthService>().isLoading ? null : _login,
                    child: context.watch<AuthService>().isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
