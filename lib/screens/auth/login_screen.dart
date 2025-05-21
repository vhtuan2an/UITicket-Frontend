import 'package:uiticket_fe/enum.dart';
import 'package:uiticket_fe/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:uiticket_fe/constants/design.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uiticket_fe/constants/design.dart';
import 'package:uiticket_fe/providers/auth_provider.dart';
import 'package:uiticket_fe/services/auth_services.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.email = '', this.password = ''});

  final String? email;
  final String? password;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _storage = const FlutterSecureStorage();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final authRequest = ref.read(authRequestProvider);
      final response = await authRequest.login(
        email: email,
        password: password,
      );
      print('Response data: ${response.data}');
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null ||
            data['userData'] == null ||
            data['userData']['accessToken'] == null ||
            data['userData']['role'] == null) {
          throw Exception('Invalid response data');
        }

        final token = data['userData']['accessToken'];
        final role = Roles.values.firstWhere(
          (r) => r.value == (data['userData']['role'] as String),
        );

        // Lưu token vào secure storage
        await AuthServices.setAuthBearerToken(token);
        final savedToken = await AuthServices.getAuthBearerToken();
        print('Saved token: $savedToken');

        if (data['userData']['name'] != null) {
          await AuthServices.setUserName(data['userData']['name']);
        }

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
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 200, width: 200),
            const SizedBox(height: kDefaultPadding * 2),
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
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
            const SizedBox(height: kDefaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                    context.go(Routes.resetPassword);
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor, // Set background color
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: kDefaultFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: kDefaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'New to UITeach?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to register screen
                    context.go(Routes.register);
                  },
                  child: const Text(
                    'Sign up',
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
