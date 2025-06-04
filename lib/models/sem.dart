import 'package:gradecalculator/models/course.dart';

class Sem {
  final String academicYearId;
  final String semId;
  final String semester;
  final String? totalUnits;
  final List<Course> courses;

  Sem({
    required this.academicYearId,
    required this.semId,
    required this.semester,
    this.totalUnits,
    this.courses = const [],
  });

  factory Sem.fromMap(Map<String, dynamic> map) => Sem(
        academicYearId: map['academicYearId'] ?? '',
        semId: map['semId'] ?? '',
        semester: map['semester'] ?? '',
        totalUnits: map['totalUnits'],
        courses: map['courses'] != null
            ? List<Course>.from(
                (map['courses'] as List)
                    .where((e) => e != null)
                    .map((e) => Course.fromMap(Map<String, dynamic>.from(e))))
            : [],
      );

  Map<String, dynamic> toMap() => {
        'academicYearId': academicYearId,
        'semId': semId,
        'semester': semester,
        'totalUnits': totalUnits,
        'courses': courses.map((e) => e.toMap()).toList(),
      };
}