import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/local_data_service.dart';
import '../map/map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String error = "";

  void login() {
    final foundUser =
        LocalDataService.authenticate(username.text, password.text);

    if (foundUser == null) {
      setState(() {
        error = 'Invalid credentials';
      });
      return;
    }

    SessionService.currentUser = foundUser;

    switch (foundUser.role) {
      case AppRole.student:
        context.go('/student');
        break;
      case AppRole.parent:
        context.go('/parent');
        break;
      case AppRole.admin:
        context.go('/admin');
        break;
    }
  }

  void fillCredentials(AppRole role) {
    final users = LocalDataService.usersByRole(role);
    if (users.isEmpty) {
      return;
    }

    final user = users.first;
    setState(() {
      error = '';
      username.text = user.username;
      password.text = user.password;
    });
  }

  Widget demoButton(AppRole role, String label, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          fillCredentials(role);
          login();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EBFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8B4FE)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF6D28D9)),
              const SizedBox(height: 5),
              Text(label.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Map
          const MapScreen(),

          // Dark overlay for readability
          Container(color: const Color(0xFF1E1B4B).withValues(alpha: 0.45)),

          // Login Card
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_bus,
                          size: 58, color: Color(0xFF6D28D9)),
                      const SizedBox(height: 10),
                      const Text(
                        'Smart Bus Access',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E1065),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use your student or parent login to view your assigned bus route.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: username,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D28D9),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 15),
                      const Text('Quick Login',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          demoButton(AppRole.student, 'student', Icons.school),
                          demoButton(
                              AppRole.parent, 'parent', Icons.family_restroom),
                          demoButton(AppRole.admin, 'admin',
                              Icons.admin_panel_settings),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sample accounts: student_akhil / 1234, parent_akhil / 1234',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
