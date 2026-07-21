import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Used to decode the JSON response

class CaseListScreen extends StatefulWidget {
  @override
  _CaseListScreenState createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  List<dynamic> cases = [];

  @override
  void initState() {
    super.initState();
    fetchCases(); // Fetch data when the screen loads
  }

  Future<void> fetchCases() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/cases')); 
    // Note: Make sure your Node.js server has a route '/api/cases'

    if (response.statusCode == 200) {
      setState(() {
        cases = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Case Management")),
      body: ListView.builder(
        itemCount: cases.length,
        itemBuilder: (context, index) {
          final c = cases[index];
          return ListTile(
            title: Text(c['clientName'] ?? 'No Name'),
            subtitle: Text("Status: ${c['status'] ?? 'N/A'}"),
          );
        },
      ),
    );
  }
}