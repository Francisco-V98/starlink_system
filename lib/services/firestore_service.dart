import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all client groups for a specific admin
  Stream<List<ClientGroup>> getClientGroups(String adminId) {
    return _db
        .collection('admins')
        .doc(adminId)
        .collection('client_groups')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClientGroup.fromJson(doc.data());
      }).toList();
    });
  }

  // Save or Update a ClientGroup for a specific admin
  Future<void> saveClientGroup(String adminId, ClientGroup group) async {
    // We use the email as the document ID to ensure uniqueness per email group within the admin's scope
    await _db
        .collection('admins')
        .doc(adminId)
        .collection('client_groups')
        .doc(group.email)
        .set(group.toJson());
  }

  // Delete a ClientGroup for a specific admin
  Future<void> deleteClientGroup(String adminId, String email) async {
    await _db
        .collection('admins')
        .doc(adminId)
        .collection('client_groups')
        .doc(email)
        .delete();
  }
}
