import 'package:gradecalculator/models/sem.dart';

class AcademicYear {
  String academicyearId;
  String userId;
  String academicYear;
  String? totalUnits;
  List<Sem?> semesters;

  AcademicYear({
    required this.academicyearId,
    required this.userId,
    required this.academicYear,
    this.totalUnits,
    this.semesters = const [],
  });

  factory AcademicYear.fromMap(Map<String, dynamic> map) => AcademicYear(
        academicyearId: map['academicyearId'] ?? '',
        userId: map['userId'] ?? '',
        academicYear: map['academicYear'] ?? '',
        totalUnits: map['totalUnits'],
        semesters: map['semesters'] != null
            ? List<Sem?>.from(
                (map['semesters'] as List)
                    .map((e) => e == null ? null : Sem.fromMap(Map<String, dynamic>.from(e))))
            : [],
      );

  Map<String, dynamic> toMap() => {
        'academicyearId': academicyearId,
        'userId': userId,
        'academicYear': academicYear,
        'totalUnits': totalUnits,
        'semesters': semesters.map((e) => e?.toMap()).toList(),
      };
}