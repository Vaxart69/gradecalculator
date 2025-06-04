import 'package:gradecalculator/models/components.dart';
import 'package:gradecalculator/models/grade_range.dart';

class Course {
  final String courseId;
  final String semId;
  final String courseName;
  final String courseCode;
  final String units;
  final String? instructor;
  final List<GradeRange> gradingSystem;
  final List<Component?> components;

  Course({
    required this.courseId,
    required this.semId,
    required this.courseName,
    required this.courseCode,
    required this.units,
    this.instructor,
    required this.gradingSystem,
    this.components = const [],
  });
}