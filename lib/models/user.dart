import 'package:gradecalculator/models/academicyear.dart';


class User {
  final String userId;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final List<AcademicYear?> academicYears;

  User({
    required this.userId,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.academicYears = const [],
  });

}