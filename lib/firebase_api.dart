import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  static final _db = FirebaseFirestore.instance;

  // Component CRUD operations
  static Future<void> addComponent(Map<String, dynamic> component) async {
    try {
      await _db.collection('components').add(component);
      print("Component added successfully");
    } catch (e) {
      print("Error adding component: $e");
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getComponents() {
    return _db.collection('components').snapshots();
  }

  static Future<void> updateComponent(String id, Map<String, dynamic> data) async {
    await _db.collection('components').doc(id).update(data);
  }

  static Future<void> deleteComponent(String id) async {
    // Delete all rows associated with this component first
    final rowsSnapshot = await _db
        .collection('rows')
        .where('componentId', isEqualTo: id)
        .get();
    
    final batch = _db.batch();
    for (var doc in rowsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the component
    batch.delete(_db.collection('components').doc(id));
    await batch.commit();
  }

  // Row CRUD operations
  static Future<String> addRow(Map<String, dynamic> row) async {
    print("FirebaseApi addRow called with: $row");
    try {
      final docRef = await _db.collection('rows').add(row);
      print("Firebase row created with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error in FirebaseApi addRow: $e");
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getRowsForComponent(String componentId) {
    print("Setting up stream for componentId: $componentId");
    return _db
        .collection('rows')
        .where('componentId', isEqualTo: componentId)
        // Remove the .orderBy('createdAt') line temporarily
        .snapshots();
  }

  static Future<void> updateRow(String id, Map<String, dynamic> data) async {
    await _db.collection('rows').doc(id).update(data);
  }

  static Future<void> deleteRow(String id) async {
    await _db.collection('rows').doc(id).delete();
  }

  // Batch update multiple rows
  static Future<void> updateMultipleRows(List<Map<String, dynamic>> rows) async {
    final batch = _db.batch();
    
    for (var row in rows) {
      if (row['id'] != null) {
        batch.update(
          _db.collection('rows').doc(row['id']),
          {
            'name': row['name'],
            'score': row['score'],
            'total': row['total'],
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
    }
    
    await batch.commit();
  }
}