import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCaseScreen extends StatefulWidget {
  @override
  _AddCaseScreenState createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> _submitCase() async {
    final url = Uri.parse('http://localhost:5000/api/cases/add');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "caseNumber": _numberController.text,
          "clientName": _clientController.text,
          "caseDescription": _descController.text,
        }),
      );

      if (mounted) { // Check if widget is still in the tree
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Case saved successfully!")));
          _numberController.clear();
          _clientController.clear();
          _descController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save: ${response.statusCode}")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Could not connect to server")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Case")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _numberController, decoration: InputDecoration(labelText: "Case Number")),
            TextField(controller: _clientController, decoration: InputDecoration(labelText: "Client Name")),
            TextField(controller: _descController, decoration: InputDecoration(labelText: "Description")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submitCase, child: Text("Save Case")),
          ],
        ),
      ),
    );
  }
}