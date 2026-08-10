import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  List<dynamic> _documents = [];
  bool _isLoading = true;
  final String _baseUrl = 'https://law-firm-system-mrek.onrender.com';

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/documents'));
      if (response.statusCode == 200) {
        setState(() {
          _documents = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDocumentDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Store New Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Document Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'File URL / Reference'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () async {
              final title = titleController.text.trim();
              final fileUrl = urlController.text.trim();
              if (title.isEmpty) return;
              Navigator.pop(context);

              try {
                final response = await http.post(
                  Uri.parse('$_baseUrl/documents'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'title': title, 'fileUrl': fileUrl}),
                );
                if (response.statusCode == 201) {
                  _fetchDocuments();
                }
              } catch (_) {}
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Document Storage'),
        backgroundColor: Colors.green.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _documents.isEmpty
              ? const Center(child: Text('No documents stored yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(Icons.insert_drive_file, color: Colors.green.shade800),
                        title: Text(doc['title'] ?? 'Untitled Document', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Reference: ${doc['fileUrl'] ?? 'N/A'}'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: _showAddDocumentDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}