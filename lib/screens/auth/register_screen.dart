import 'package:uiticket_fe/constants/design.dart';
import 'package:uiticket_fe/enum.dart';
import 'package:uiticket_fe/requests/auth_request.dart';
import 'package:uiticket_fe/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:uiticket_fe/screens/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.role = '',
    this.name = '',
  });

  final String? email;
  final String? password;
  final String? confirmPassword;
  final String? role;
  final String? name;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final _authRequest = AuthRequest();
  final _storage = const FlutterSecureStorage();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _selectedRole; // Thay đổi ở đây

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
    _confirmPasswordController = TextEditingController(text: widget.confirmPassword);
    _nameController = TextEditingController(text: widget.name);
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final role = _selectedRole; // Sử dụng giá trị từ biến trạng thái
    final name = _nameController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    } else if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    } else if (role == null || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    } else if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final response = await _authRequest.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        name: name,
      );
      print('Response data: ${response.data}');
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null ||
            data['data'] == null ||
            data['accessToken'] == null) {
          throw Exception('Invalid response data');
        }

        final token = data['accessToken'];
        final role = Roles.values.firstWhere(
          (r) => r.value == (data['data']['role'] as String),
        );

        // Lưu token vào secure storage
        await _storage.write(key: 'token', value: token);

        switch (role) {
          case Roles.admin:
            context.go(Routes.adminPage);
            break;
          case Roles.event_creator:
            context.go(Routes.eventCreatorPage);
            break;
          case Roles.ticket_buyer:
            context.go(Routes.ticketBuyerPage);
            break;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              hint: const Text(
                'Select your role',
                style: TextStyle(color: Colors.grey),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'event_creator',
                  child: Text('Event Creator'),
                ),
                DropdownMenuItem(
                  value: 'ticket_buyer',
                  child: Text('Ticket Buyer'),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedRole = value; // Lưu giá trị được chọn vào biến trạng thái
                });
              },
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Handle registration logic here
                _handleRegister();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: kPrimaryColor,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have account?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to login screen
                    context.go(Routes.login);
                  },
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}