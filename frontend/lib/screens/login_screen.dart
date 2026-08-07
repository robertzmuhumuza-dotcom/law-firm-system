import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Your live Render backend base URL
  final String _baseUrl = 'https://law-firm-system-mrek.onrender.com';

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        throw Exception('Server error (${response.statusCode}): Received HTML instead of JSON.');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );
        // TODO: Navigate to your Dashboard/Home screen here
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: resetController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Enter your email address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(context);

              try {
                final response = await http.post(
                  Uri.parse('$_baseUrl/forgot-password'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email}),
                );
                final data = jsonDecode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(data['message'] ?? 'Password reset processed.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to send reset request.')),
                );
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRegisterDialog() {
    final regEmailController = TextEditingController();
    final regPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: regEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            onPressed: () async {
              final email = regEmailController.text.trim();
              final password = regPasswordController.text.trim();
              if (email.isEmpty || password.isEmpty) return;
              Navigator.pop(context);

              try {
                final response = await http.post(
                  Uri.parse('$_baseUrl/register'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email, 'password': password}),
                );
                final data = jsonDecode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(data['message'] ?? 'Registration complete.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration failed.')),
                );
              }
            },
            child: const Text('Register', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Law System Login'),
        backgroundColor: Colors.orange.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                ),
                onPressed: _isLoading ? null : _loginUser,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text('Forgot Password?'),
            ),
            TextButton(
              onPressed: _showRegisterDialog,
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}