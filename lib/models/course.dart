import 'package:gradecalculator/models/components.dart';
import 'package:gradecalculator/models/grade_range.dart';

class Course {
  final String courseId;
  final String userId; // Direct reference to user
  final String courseName;
  final String courseCode;
  final String units;
  final String? instructor;
  final String academicYear; // e.g., "2024-2025"
  final String semester; // e.g., "1st Semester", "2nd Semester", "Summer"
  final List<GradeRange> gradingSystem;
  final List<Component?> components;

  Course({
    required this.courseId,
    required this.userId,
    required this.courseName,
    required this.courseCode,
    required this.units,
    this.instructor,
    required this.academicYear,
    required this.semester,
    required this.gradingSystem,
    this.components = const [],
  });

  factory Course.fromMap(Map<String, dynamic> map) => Course(
        courseId: map['courseId'] ?? '',
        userId: map['userId'] ?? '',
        courseName: map['courseName'] ?? '',
        courseCode: map['courseCode'] ?? '',
        units: map['units'] ?? '',
        instructor: map['instructor'],
        academicYear: map['academicYear'] ?? '',
        semester: map['semester'] ?? '',
        gradingSystem: map['gradingSystem'] != null
            ? List<GradeRange>.from(
                (map['gradingSystem'] as List)
                    .where((e) => e != null)
                    .map((e) => GradeRange.fromMap(Map<String, dynamic>.from(e))))
            : [],
        components: map['components'] != null
            ? List<Component?>.from(
                (map['components'] as List)
                    .map((e) => e == null ? null : Component.fromMap(Map<String, dynamic>.from(e))))
            : [],
      );

  Map<String, dynamic> toMap() => {
        'courseId': courseId,
        'userId': userId,
        'courseName': courseName,
        'courseCode': courseCode,
        'units': units,
        'instructor': instructor,
        'academicYear': academicYear,
        'semester': semester,
        'gradingSystem': gradingSystem.map((e) => e.toMap()).toList(),
        'components': components.map((e) => e?.toMap()).toList(),
      };
}