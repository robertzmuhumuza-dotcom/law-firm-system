import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MaterialApp(home: CaseManagerApp()));

class CaseManagerApp extends StatefulWidget {
  @override
  _CaseManagerAppState createState() => _CaseManagerAppState();
}

class _CaseManagerAppState extends State<CaseManagerApp> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController detailCtrl = TextEditingController();
  
  // 1. Perform Authentication
  Future<void> login() async {
    try {
      final res = await http.post(Uri.parse('http://localhost:5000/api/login'));
      if (res.statusCode == 200) {
        final token = json.decode(res.body)['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged in!")));
      }
    } catch (e) { print(e); }
  }

  // 2. Add a Case (Authenticated)
  Future<void> saveCase() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    await http.post(
      Uri.parse('http://localhost:5000/api/cases'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"clientName": nameCtrl.text, "details": detailCtrl.text}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Legal AI System")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          ElevatedButton(onPressed: login, child: Text("Authenticate")),
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Client Name")),
          TextField(controller: detailCtrl, decoration: InputDecoration(labelText: "Case Details")),
          SizedBox(height: 20),
          ElevatedButton(onPressed: saveCase, child: Text("Submit Case to Database")),
        ]),
      ),
    );
  }
}