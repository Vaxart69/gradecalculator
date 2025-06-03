import 'package:gradecalculator/models/grade_range.dart';

class Course {
  final String courseId;
  final String semId;
  final String courseName;
  final String courseCode;
  final String units;
  final String? instructor;
  final List<GradeRange> gradingSystem;

  Course({
    required this.courseId,
    required this.semId,
    required this.courseName,
    required this.courseCode,
    required this.units,
    this.instructor,
    this.gradingSystem = const [],
  });
}