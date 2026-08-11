import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  List documents = [];
  bool isLoading = true;
  final String _baseUrl = 'https://law-firm-system-mrek.onrender.com';

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/documents'));
      if (response.statusCode == 200) {
        setState(() {
          documents = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAddDocDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Store Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Document Title')),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: 'File URL / Reference')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await http.post(
                  Uri.parse('$_baseUrl/documents'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'title': titleController.text,
                    'fileUrl': urlController.text.isEmpty ? 'N/A' : urlController.text,
                  }),
                );
                Navigator.pop(context);
                fetchDocuments();
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Storage'), backgroundColor: Colors.green.shade800),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : documents.isEmpty
              ? const Center(child: Text('No documents stored yet.'))
              : ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.description, color: Colors.green),
                        title: Text(doc['title'] ?? ''),
                        subtitle: Text('Uploaded: ${doc['uploadedAt']}'),
                        trailing: const Icon(Icons.cloud_done, color: Colors.grey),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: _showAddDocDialog,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }
}