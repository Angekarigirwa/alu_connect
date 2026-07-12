import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityService {
  final CollectionReference _opportunities =
      FirebaseFirestore.instance.collection('opportunities');

  Stream<List<Opportunity>> getOpportunities() {
    return _opportunities
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Opportunity.fromFirestore(doc)).toList());
  }

  Future<void> postOpportunity(Opportunity opportunity) async {
    await _opportunities.add(opportunity.toMap());
  }

  Future<void> applyToOpportunity({
    required String opportunityId,
    required String opportunityTitle,
    required String userId,
  }) async {
    await FirebaseFirestore.instance.collection('applications').add({
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'userId': userId,
      'appliedAt': FieldValue.serverTimestamp(),
      'status': 'Applied',
    });
  }

  Stream<List<Map<String, dynamic>>> getUserApplications(String userId) {
    return FirebaseFirestore.instance
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }
}
