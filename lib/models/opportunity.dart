import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String title;
  final String organization;
  final String category;
  final List<String> tags;
  final String description;
  final String type; // e.g. "Part-time", "Remote", "On-campus"
  final String postedBy; // uid of the user who posted it
  final DateTime postedAt;

  Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.category,
    required this.tags,
    required this.description,
    required this.type,
    required this.postedBy,
    required this.postedAt,
  });

  factory Opportunity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Opportunity(
      id: doc.id,
      title: data['title'] ?? '',
      organization: data['organization'] ?? '',
      category: data['category'] ?? 'Other',
      tags: List<String>.from(data['tags'] ?? []),
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      postedBy: data['postedBy'] ?? '',
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'organization': organization,
      'category': category,
      'tags': tags,
      'description': description,
      'type': type,
      'postedBy': postedBy,
      'postedAt': FieldValue.serverTimestamp(),
    };
  }
}
