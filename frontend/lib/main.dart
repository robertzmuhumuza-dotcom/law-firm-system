import 'package:flutter/material.dart';
import 'auth_screen.dart';

void main() {
  runApp(LawFirmApp());
}

class LawFirmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Law Firm System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthScreen(),
    );
  }
}