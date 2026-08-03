import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegistering = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  void _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _message = '';
      _isSuccess = false;
    });

    Map<String, dynamic> result;

    if (_isRegistering) {
      result = await ApiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    setState(() {
      _isLoading = false;
      _message = result['message'] ?? (result['success'] ? 'Success!' : 'Action failed');
      _isSuccess = result['success'];
    });

    if (_isSuccess) {
      if (!mounted) return;

      if (_isRegistering) {
        // Switch back to login view after successful registration
        setState(() {
          _isRegistering = false;
          _message = 'Registration successful! Please login.';
        });
      } else {
        // Navigate to Dashboard on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Law Firm System - Register' : 'Law Firm System - Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _message,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_isRegistering) ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isRegistering ? 'Register Account' : 'Login to Server',
                              style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                        _message = '';
                      });
                    },
                    child: Text(_isRegistering
                        ? 'Already have an account? Login here'
                        : 'Don\'t have an account? Register here'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}