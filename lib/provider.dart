import 'package:flutter/material.dart';
import 'firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ComponentProvider with ChangeNotifier {
  List<Map<String, dynamic>> _components = [];
  Map<String, List<Map<String, dynamic>>> _componentRows = {};
  Map<String, StreamSubscription> _rowSubscriptions = {};
  String? _selectedComponentId;
  
  // Add debouncing for notifications
  Timer? _notifyTimer;

  List<Map<String, dynamic>> get components => _components;
  String? get selectedComponentId => _selectedComponentId;
  
  // Get rows for the currently selected component
  List<Map<String, dynamic>> get rows {
    if (_selectedComponentId == null) return [];
    return _componentRows[_selectedComponentId] ?? [];
  }
  
  List<Map<String, dynamic>> getRowsForComponent(String componentId) {
    return _componentRows[componentId] ?? [];
  }

  // Set the selected component
  void setSelectedComponent(String? componentId) {
    if (_selectedComponentId != componentId) {
      _selectedComponentId = componentId;
      _debouncedNotify();
    }
  }

  // Debounced notify to prevent excessive UI updates
  void _debouncedNotify() {
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }

  // Listen to components changes
  void listenToComponents() {
    FirebaseApi.getComponents().listen((snapshot) {
      final newComponents = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Check for new components and set up row listeners
      for (var component in newComponents) {
        final componentId = component['id'];
        if (!_rowSubscriptions.containsKey(componentId)) {
          _listenToRowsForComponent(componentId);
        }
      }

      // Check for deleted components and clean up listeners
      final newComponentIds = newComponents.map((c) => c['id']).toSet();
      final oldComponentIds = _components.map((c) => c['id']).toSet();
      
      for (var oldId in oldComponentIds) {
        if (!newComponentIds.contains(oldId)) {
          _rowSubscriptions[oldId]?.cancel();
          _rowSubscriptions.remove(oldId);
          _componentRows.remove(oldId);
        }
      }

      _components = newComponents;
      _debouncedNotify(); // Use debounced notify
    });
  }

  // Listen to rows for a specific component
  void _listenToRowsForComponent(String componentId) {
    final subscription = FirebaseApi.getRowsForComponent(componentId).listen((snapshot) {
      final newRows = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Only update if data actually changed
      final currentRows = _componentRows[componentId] ?? [];
      if (!_listsEqual(currentRows, newRows)) {
        _componentRows[componentId] = newRows;
        
        // Only notify if this affects the UI (all components are shown)
        _debouncedNotify();
      }
    }, onError: (error) {
      print("Error listening to rows for component $componentId: $error");
    });

    _rowSubscriptions[componentId] = subscription;
  }
  
  // Helper method to compare lists for changes
  bool _listsEqual(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      final map1 = list1[i];
      final map2 = list2[i];
      
      if (map1['id'] != map2['id'] || 
          map1['name'] != map2['name'] || 
          map1['score'] != map2['score'] || 
          map1['total'] != map2['total']) {
        return false;
      }
    }
    return true;
  }

  // Component operations
  Future<void> addComponent(Map<String, dynamic> component) async {
    component['createdAt'] = FieldValue.serverTimestamp();
    await FirebaseApi.addComponent(component);
  }

  Future<void> updateComponent(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await FirebaseApi.updateComponent(id, data);
  }

  Future<void> deleteComponent(String id) async {
    await FirebaseApi.deleteComponent(id);
  }

  // Row operations
  Future<String> addRow(String componentId, {String name = '', String score = '', String total = ''}) async {
    try {
      final row = {
        'componentId': componentId,
        'name': name,
        'score': score,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final rowId = await FirebaseApi.addRow(row);
      return rowId;
    } catch (e) {
      print("Error in provider addRow: $e");
      rethrow;
    }
  }

  Future<void> updateRow(String rowId, {String? name, String? score, String? total}) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (name != null) data['name'] = name;
    if (score != null) data['score'] = score;
    if (total != null) data['total'] = total;
    
    await FirebaseApi.updateRow(rowId, data);
  }

  Future<void> deleteRow(String rowId) async {
    await FirebaseApi.deleteRow(rowId);
  }

  Future<void> updateMultipleRows(List<Map<String, dynamic>> rows) async {
    await FirebaseApi.updateMultipleRows(rows);
  }

  @override
  void dispose() {
    _notifyTimer?.cancel();
    for (var subscription in _rowSubscriptions.values) {
      subscription.cancel();
    }
    _rowSubscriptions.clear();
    super.dispose();
  }
}