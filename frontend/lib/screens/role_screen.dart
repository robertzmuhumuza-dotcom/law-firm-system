import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoleScreen extends StatefulWidget {
  const RoleScreen({Key? key}) : super(key: key);

  @override
  _RoleScreenState createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  List roles = [];
  bool isLoading = true;
  final String _baseUrl = 'https://law-firm-system-mrek.onrender.com';

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/roles'));
      if (response.statusCode == 200) {
        setState(() {
          roles = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAddRoleDialog() {
    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final caseIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'User Email / ID')),
            TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role (e.g. Lead Counsel)')),
            TextField(controller: caseIdController, decoration: const InputDecoration(labelText: 'Case ID')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty && roleController.text.isNotEmpty) {
                await http.post(
                  Uri.parse('$_baseUrl/roles'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'userId': emailController.text,
                    'role': roleController.text,
                    'caseId': caseIdController.text,
                  }),
                );
                Navigator.pop(context);
                fetchRoles();
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role Assignments'), backgroundColor: Colors.purple.shade800),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roles.isEmpty
              ? const Center(child: Text('No role assignments recorded yet.'))
              : ListView.builder(
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final r = roles[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.supervised_user_circle, color: Colors.purple),
                        title: Text(r['role'] ?? ''),
                        subtitle: Text('User: ${r['userId']}\nCase: ${r['caseId']}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade800,
        onPressed: _showAddRoleDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}