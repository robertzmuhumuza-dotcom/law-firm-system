import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; 

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

  Future<void> _submit() async {
    final url = Uri.parse('http://localhost:5000/api/auth/${isLogin ? 'login' : 'register'}');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": _emailController.text, 
        "password": _passwordController.text
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (isLogin) {
        final data = json.decode(response.body);
        // You can save this role locally (e.g., using shared_preferences later)
        final String userRole = data['role']; 
        print("Logged in as: $userRole"); 
        
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Dashboard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registered! Now log in.")));
        setState(() => isLogin = true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Auth failed: ${response.body}")));
    }
  }
  
  // ... rest of your build method remains the same ...