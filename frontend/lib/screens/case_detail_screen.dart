import 'package:flutter/material.dart';

class CaseListScreen extends StatelessWidget {
  // Mock data for demonstration; replace this with your actual database call
  final List<Map<String, String>> cases = [
    {'id': '1', 'title': 'Meera Investments Case', 'status': 'Open'},
    {'id': '2', 'title': 'Heritage Oil Dispute', 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Case Management")),
      body: ListView.builder(
        itemCount: cases.length,
        itemBuilder: (context, index) {
          final caseItem = cases[index];
          return ListTile(
            title: Text(caseItem['title']!),
            subtitle: Text("Status: ${caseItem['status']}"),
            // The 'trailing' widget must be a single widget. 
            // We use a Row to hold multiple items (like an icon and a text).
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to your CaseDetailsScreen
            },
          );
        },
      ),
    );
  }
}