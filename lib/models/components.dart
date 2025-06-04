import 'package:gradecalculator/models/records.dart';

class Component {
  final String componentId;
  final String componentName;
  final double weight;
  final List<Records>? records; 
  final String courseId;

  Component({
    required this.componentId,
    required this.componentName,
    required this.weight,
    required this.courseId,
    this.records = const [],
  });

  factory Component.fromMap(Map<String, dynamic> map) => Component(
        componentId: map['componentId'] ?? '',
        componentName: map['componentName'] ?? '',
        weight: (map['weight'] is int)
            ? (map['weight'] as int).toDouble()
            : (map['weight'] ?? 0.0),
        courseId: map['courseId'] ?? '',
        records: map['records'] != null
            ? List<Records>.from(
                (map['records'] as List)
                    .where((e) => e != null)
                    .map((e) => Records.fromMap(Map<String, dynamic>.from(e))))
            : [],
      );

  Map<String, dynamic> toMap() => {
        'componentId': componentId,
        'componentName': componentName,
        'weight': weight,
        'courseId': courseId,
        'records': records?.map((e) => e.toMap()).toList() ?? [],
      };
}