import 'package:gradecalculator/models/course.dart';

class Sem {
  final String userId;
  final String semId;
  final String semester;
  final String academicyear;
  final String? totalUnits;
  final List <Course> courses;

  Sem({
    required this.userId,
    required this.semId,
    required this.semester,
    required this.academicyear,
    this.totalUnits,
    this.courses = const [],
  });

}