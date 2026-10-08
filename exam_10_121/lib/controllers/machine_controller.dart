import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/machine_model.dart';

class MachineController {
  final _col = FirebaseFirestore.instance.collection('machines');

  // Create
  Future<void> add(MachineModel m) async {
    await _col.add({...m.toMap(), 'createdAt': FieldValue.serverTimestamp()});
  }

  // Read (Real-time)
  Stream<QuerySnapshot<Map<String, dynamic>>> stream() =>
      _col.orderBy('createdAt', descending: true).snapshots();

  // Update
  Future<void> update(String id, MachineModel m) async {
    await _col.doc(id).update(m.toMap());
  }

  // Delete
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
