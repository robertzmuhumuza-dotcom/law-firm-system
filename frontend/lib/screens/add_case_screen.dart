import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCaseScreen extends StatefulWidget {
  @override
  _AddCaseScreenState createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _caseNumberController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitCase() async {
    setState(() { _isLoading = true; });
    final url = Uri.parse('https://law-firm-system-4ccx.onrender.com/api/cases');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'caseNumber': _caseNumberController.text,
          'clientName': _clientNameController.text,
          'details': _detailsController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Case added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add case: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to server: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Case')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _caseNumberController, decoration: InputDecoration(labelText: 'Case Number')),
            TextField(controller: _clientNameController, decoration: InputDecoration(labelText: 'Client Name')),
            TextField(controller: _detailsController, decoration: InputDecoration(labelText: 'Case Details')),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submitCase, child: Text('Save Case')),
          ],
        ),
      ),
    );
  }
}