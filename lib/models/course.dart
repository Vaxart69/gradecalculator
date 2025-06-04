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

  factory Course.fromMap(Map<String, dynamic> map) => Course(
        courseId: map['courseId'] ?? '',
        semId: map['semId'] ?? '',
        courseName: map['courseName'] ?? '',
        courseCode: map['courseCode'] ?? '',
        units: map['units'] ?? '',
        instructor: map['instructor'],
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
        'semId': semId,
        'courseName': courseName,
        'courseCode': courseCode,
        'units': units,
        'instructor': instructor,
        'gradingSystem': gradingSystem.map((e) => e.toMap()).toList(),
        'components': components.map((e) => e?.toMap()).toList(),
      };
}