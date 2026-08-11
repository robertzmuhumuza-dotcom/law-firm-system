import 'package:flutter/material.dart';
import 'case_tracking_screen.dart';
import 'document_screen.dart';
import 'role_screen.dart';
import 'ai_chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Law Firm Management System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Managing Partner Dashboard',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a module below to manage your firm\'s workflow:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // 1. CASE TRACKING MODULE
                  _DashboardCard(
                    title: 'Case Tracking',
                    icon: Icons.folder,
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CaseTrackingScreen(),
                        ),
                      );
                    },
                  ),

                  // 2. AI & EVIDENCE MODULE
                  _DashboardCard(
                    title: 'AI & Evidence',
                    icon: Icons.smart_toy,
                    iconColor: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiChatScreen(),
                        ),
                      );
                    },
                  ),

                  // 3. DOCUMENT STORAGE MODULE
                  _DashboardCard(
                    title: 'Document Storage',
                    icon: Icons.description,
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DocumentScreen(),
                        ),
                      );
                    },
                  ),

                  // 4. ROLE ASSIGNMENTS MODULE
                  _DashboardCard(
                    title: 'Role Assignments',
                    icon: Icons.supervised_user_circle,
                    iconColor: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleScreen(),
                        ),
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
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}