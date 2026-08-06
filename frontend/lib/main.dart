import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const LawFirmApp());
}

class LawFirmApp extends StatelessWidget {
  const LawFirmApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Law Firm System',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}