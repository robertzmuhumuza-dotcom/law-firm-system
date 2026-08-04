import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CaseListScreen extends StatefulWidget {
  @override
  _CaseListScreenState createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  List cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCases();
  }

  Future<void> _fetchCases() async {
    final url = Uri.parse('https://law-firm-system-4ccx.onrender.com/api/cases');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          cases = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Law Firm Cases')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cases.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cases[index]['caseNumber'] ?? 'No Number'),
                  subtitle: Text(cases[index]['clientName'] ?? 'No Client'),
                );
              },
            ),
    );
  }
}