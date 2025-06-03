import 'package:gradecalculator/models/sem.dart';

class User {
  final String userId;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final List<Sem?> sems;

  User({
    required this.userId,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.sems = const [],
  });

}