import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../services/opportunity_service.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final _opportunityService = OpportunityService();
  bool _isApplying = false;

  Future<void> _apply() async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) return;

    setState(() => _isApplying = true);

    try {
      await _opportunityService.applyToOpportunity(
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        userId: userId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    return Scaffold(
      appBar: AppBar(title: const Text("Opportunity Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opp.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(opp.organization,
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: opp.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.work_outline, size: 18),
                const SizedBox(width: 8),
                Text(opp.type),
              ],
            ),
            const SizedBox(height: 20),
            const Text("About",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(opp.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isApplying ? null : _apply,
                child: _isApplying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
