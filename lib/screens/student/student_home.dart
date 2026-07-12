import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/opportunity_service.dart';
import '../../models/opportunity.dart';
import 'opportunity_detail_screen.dart';
import 'post_opportunity_screen.dart';
import 'my_applications_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final _opportunityService = OpportunityService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final _categories = ['All', 'Engineering', 'Design', 'Marketing', 'Data', 'Other'];

  List<Opportunity> _filterOpportunities(List<Opportunity> opportunities) {
    return opportunities.where((opp) {
      final matchesCategory =
          _selectedCategory == 'All' || opp.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          opp.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opp.organization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opp.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ALU Connect"),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: "My Applications",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Post"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostOpportunityScreen()),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              "Welcome, ${auth.currentUser?.email ?? 'Student'}",
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search opportunities...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Opportunity>>(
              stream: _opportunityService.getOpportunities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final opportunities = _filterOpportunities(snapshot.data ?? []);
                if (opportunities.isEmpty) {
                  return const Center(
                    child: Text("No opportunities match your search."),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: opportunities.length,
                  itemBuilder: (context, index) {
                    final opp = opportunities[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(opp.title,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${opp.organization} • ${opp.type}"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OpportunityDetailScreen(opportunity: opp),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
