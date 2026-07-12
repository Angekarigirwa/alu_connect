import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../services/opportunity_service.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();
  String _category = 'Engineering';
  String _type = 'Part-time';
  bool _isSaving = false;

  final _categories = ['Engineering', 'Design', 'Marketing', 'Data', 'Other'];
  final _types = ['Part-time', 'Remote', 'On-campus'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    setState(() => _isSaving = true);

    final opportunity = Opportunity(
      id: '',
      title: _titleController.text.trim(),
      organization: _orgController.text.trim(),
      category: _category,
      tags: _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      description: _descController.text.trim(),
      type: _type,
      postedBy: userId,
      postedAt: DateTime.now(),
    );

    try {
      await OpportunityService().postOpportunity(opportunity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opportunity posted!")),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Opportunity")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orgController,
                decoration: const InputDecoration(labelText: "Organization / Startup", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: "Type", border: OutlineInputBorder()),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                    labelText: "Skills (comma-separated)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Post Opportunity"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
