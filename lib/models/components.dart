class Component {
  final String componentId;
  final String componentName;
  final double weight;
  final List<Record>? records;
  final String courseId;

  Component({
    required this.componentId,
    required this.componentName,
    required this.weight,
    required this.courseId,
    this.records = const [],
  });
}