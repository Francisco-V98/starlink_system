import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'client_groups';

  // Get all client groups
  Stream<List<ClientGroup>> getClientGroups() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClientGroup.fromJson(doc.data());
      }).toList();
    });
  }

  // Save or Update a ClientGroup
  Future<void> saveClientGroup(ClientGroup group) async {
    // We use the email as the document ID to ensure uniqueness per email group
    await _db.collection(_collection).doc(group.email).set(group.toJson());
  }

  // Delete a ClientGroup
  Future<void> deleteClientGroup(String email) async {
    await _db.collection(_collection).doc(email).delete();
  }
}
