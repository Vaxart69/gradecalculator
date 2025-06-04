import 'package:gradecalculator/models/sem.dart';

class AcademicYear{

  String acadeicyearId;
  String userId;
  String academicYear;
  String? totalUnits;
  List<Sem?> semesters;
  
  AcademicYear({
    required this.acadeicyearId,
    required this.userId,
    required this.academicYear,
    this.totalUnits,
    this.semesters = const [],
  });
}