import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoleScreen extends StatefulWidget {
  const RoleScreen({Key? key}) : super(key: key);

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  List<dynamic> _roles = [];
  bool _isLoading = true;

  final String _baseUrl = 'https://law-firm-system-mrek.onrender.com';

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/roles'));

      if (response.statusCode == 200) {
        setState(() {
          _roles = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load role assignments.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _showAssignRoleDialog() {
    final userController = TextEditingController();
    final roleController = TextEditingController();
    final caseIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(labelText: 'User Email / ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role (e.g., Lead Counsel, Researcher)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caseIdController,
              decoration: const InputDecoration(labelText: 'Case ID (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade800),
            onPressed: () async {
              final userId = userController.text.trim();
              final role = roleController.text.trim();
              final caseId = caseIdController.text.trim();

              if (userId.isEmpty || role.isEmpty) return;
              Navigator.pop(context);

              try {
                final response = await http.post(
                  Uri.parse('$_baseUrl/roles'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'userId': userId,
                    'role': role,
                    'caseId': caseId.isEmpty ? 'N/A' : caseId,
                  }),
                );

                if (response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Role assigned successfully!')),
                  );
                  _fetchRoles();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to assign role.')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error connecting to backend.')),
                );
              }
            },
            child: const Text('Assign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Assignment Management'),
        backgroundColor: Colors.purple.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _roles.isEmpty
              ? const Center(child: Text('No role assignments recorded yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final item = _roles[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(Icons.assignment_ind, color: Colors.purple.shade800),
                        title: Text(
                          'User: ${item['userId'] ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Role: ${item['role']} | Case ID: ${item['caseId']}'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade800,
        onPressed: _showAssignRoleDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}