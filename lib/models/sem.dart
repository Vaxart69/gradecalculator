import 'package:gradecalculator/models/course.dart';

class Sem {
  final String academicYearId;
  final String semId;
  final String semester;
  final String? totalUnits;
  final List <Course> courses;

  Sem({
    required this.academicYearId,
    required this.semId,
    required this.semester,
    this.totalUnits,
    this.courses = const [],
  });

}