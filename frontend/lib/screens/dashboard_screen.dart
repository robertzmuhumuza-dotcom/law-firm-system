import 'package:flutter/material.dart';
import 'ai_chat_screen.dart'; // Import your AI Chat screen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Law Firm Management System'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Managing Partner Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a module below to manage your firm\'s workflow:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Case Tracking',
                    icon: Icons.folder_shared,
                    color: Colors.blue,
                    onTap: () {
                      _showFeatureDialog(context, 'Case Tracking Module');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Role Assignments',
                    icon: Icons.assignment_ind,
                    color: Colors.orange,
                    onTap: () {
                      _showFeatureDialog(context, 'Role Assignments Module');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Document Storage',
                    icon: Icons.cloud_upload,
                    color: Colors.green,
                    onTap: () {
                      _showFeatureDialog(context, 'Document Storage Module');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'AI Legal Co-Pilot & Evidence',
                    icon: Icons.psychology,
                    color: Colors.purple,
                    onTap: () {
                      // Navigate directly to your live AI chat and evidence analyzer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AIChatScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String moduleName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(moduleName),
        content: Text('The $moduleName is ready for integration with your backend database endpoints.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}