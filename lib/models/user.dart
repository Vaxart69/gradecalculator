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

  factory User.fromMap(Map<String, dynamic> map) => User(
        userId: map['userId'] ?? '',
        username: map['username'] ?? '',
        firstname: map['firstname'] ?? '',
        lastname: map['lastname'] ?? '',
        email: map['email'] ?? '',
        academicYears: map['academicYears'] != null
            ? List<AcademicYear?>.from(
                (map['academicYears'] as List)
                    .map((e) => e == null ? null : AcademicYear.fromMap(e)))
            : [],
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'username': username,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'academicYears': academicYears.map((e) => e?.toMap()).toList(),
      };
}