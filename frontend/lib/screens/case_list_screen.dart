import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({Key? key}) : super(key: key);

  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  List<dynamic> _cases = [];
  bool _isLoading = true;

  final String _baseUrl = 'https://law-firm-system-mrek.onrender.com';

  @override
  void initState() {
    super.initState();
    _fetchCases();
  }

  Future<void> _fetchCases() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/cases'));

      if (response.statusCode == 200) {
        setState(() {
          _cases = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load active cases.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Case Tracking'),
        backgroundColor: Colors.orange.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _cases.isEmpty
              ? const Center(child: Text('No active cases registered.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cases.length,
                  itemBuilder: (context, index) {
                    final caseItem = _cases[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Icon(Icons.folder, color: Colors.orange.shade800),
                        ),
                        title: Text(
                          caseItem['title'] ?? 'Untitled Case',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Case No: ${caseItem['caseNumber'] ?? 'N/A'}'),
                            const SizedBox(height: 2),
                            Text(
                              'Status: ${caseItem['status'] ?? 'Pending'}',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}