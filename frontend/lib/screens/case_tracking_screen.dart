import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CaseTrackingScreen extends StatefulWidget {
  const CaseTrackingScreen({Key? key}) : super(key: key);

  @override
  _CaseTrackingScreenState createState() => _CaseTrackingScreenState();
}

class _CaseTrackingScreenState extends State<CaseTrackingScreen> {
  List cases = [];
  bool isLoading = true;
  final String _baseUrl = 'https://law-firm-system-mrek.onrender.com';

  @override
  void initState() {
    super.initState();
    fetchCases();
  }

  Future<void> fetchCases() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/cases'));
      if (response.statusCode == 200) {
        setState(() {
          cases = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAddCaseDialog() {
    final caseNumController = TextEditingController();
    final titleController = TextEditingController();
    final statusController = TextEditingController(text: 'Active Hearing');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Case'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: caseNumController, decoration: const InputDecoration(labelText: 'Case Number')),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Case Title')),
            TextField(controller: statusController, decoration: const InputDecoration(labelText: 'Status')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (caseNumController.text.isNotEmpty && titleController.text.isNotEmpty) {
                await http.post(
                  Uri.parse('$_baseUrl/cases'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'caseNumber': caseNumController.text,
                    'title': titleController.text,
                    'status': statusController.text,
                  }),
                );
                Navigator.pop(context);
                fetchCases();
              }
            },
            child: const Text('Save Case'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Case Tracking'), backgroundColor: Colors.blue.shade800),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cases.isEmpty
              ? const Center(child: Text('No cases recorded yet.'))
              : ListView.builder(
                  itemCount: cases.length,
                  itemBuilder: (context, index) {
                    final item = cases[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.folder, color: Colors.blue),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text('Case No: ${item['caseNumber']}\nStatus: ${item['status']}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        onPressed: _showAddCaseDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}