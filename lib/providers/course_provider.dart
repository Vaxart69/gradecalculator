import 'package:flutter/material.dart';
import 'package:gradecalculator/api/course_api.dart';
import 'package:gradecalculator/models/course.dart';

class CourseProvider with ChangeNotifier {
  final CourseApi _courseApi = CourseApi();
  
  // Selected course state
  Course? _selectedCourse;
  
  // Getters
  Course? get selectedCourse => _selectedCourse;
  
  // Select a course (when user taps on course card)
  void selectCourse(Course course) {
    _selectedCourse = course;
    notifyListeners();
  }
  
  // Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }
  
  // Add course (existing functionality)
  Future<String?> addCourse(Course course) async {
    String? result = await _courseApi.addCourse(course);
    notifyListeners();
    return result;
  }
  
  // Update selected course with new data (for when components are added/modified)
  void updateSelectedCourse(Course updatedCourse) {
    if (_selectedCourse != null && _selectedCourse!.courseId == updatedCourse.courseId) {
      _selectedCourse = updatedCourse;
      notifyListeners();
    }
  }
  
  // Add component to selected course (placeholder for future implementation)
  Future<String?> addComponentToSelectedCourse(dynamic component) async {
    if (_selectedCourse == null) return "No course selected";
    
    try {
      // TODO: Implement component addition logic
      // This will involve updating the course's components list
      // and syncing with Firebase
      
      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Failed to add component: $e";
    }
  }
  
  // Calculate and update final grade (placeholder for future implementation)
  void calculateFinalGrade() {
    if (_selectedCourse == null) return;
    
    // TODO: Implement grade calculation logic based on components
    // Update the course's grading system with calculated grade
    
    notifyListeners();
  }
  
  // Update only the grade of the selected course
  void updateSelectedCourseGrade(double? newGrade) {
    if (_selectedCourse != null) {
      _selectedCourse = Course(
        courseId: _selectedCourse!.courseId,
        userId: _selectedCourse!.userId,
        courseName: _selectedCourse!.courseName,
        courseCode: _selectedCourse!.courseCode,
        units: _selectedCourse!.units,
        instructor: _selectedCourse!.instructor,
        academicYear: _selectedCourse!.academicYear,
        semester: _selectedCourse!.semester,
        gradingSystem: _selectedCourse!.gradingSystem,
        components: _selectedCourse!.components,
        grade: newGrade, // <-- update grade
      );
      notifyListeners();
    }
  }
}