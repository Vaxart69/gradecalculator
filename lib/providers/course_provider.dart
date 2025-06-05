import 'package:flutter/material.dart';
import 'package:gradecalculator/api/course_api.dart';
import 'package:gradecalculator/models/course.dart';

class CourseProvider with ChangeNotifier {
  final CourseApi _courseApi = CourseApi();

  Future<String?> addCourse(Course course) async {
    String? result = await _courseApi.addCourse(course);
    notifyListeners();
    return result;
  }
}