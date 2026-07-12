import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/opportunity_service.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    final service = OpportunityService();

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getUserApplications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final applications = snapshot.data ?? [];
          if (applications.isEmpty) {
            return const Center(child: Text("No applications yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(app['opportunityTitle'] ?? ''),
                  trailing: Chip(label: Text(app['status'] ?? 'Applied')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
