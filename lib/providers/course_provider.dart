import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradecalculator/api/course_api.dart';
import 'package:gradecalculator/models/course.dart';
import 'package:gradecalculator/models/components.dart';
import 'package:gradecalculator/models/records.dart';

class CourseProvider with ChangeNotifier {
  final CourseApi _courseApi = CourseApi();
  
  // Selected course state
  Course? _selectedCourse;
  
  // Getters
  Course? get selectedCourse => _selectedCourse;
  
  // Select a course (when user taps on course card)
  void selectCourse(Course course) async {
    _selectedCourse = course;
    
    // Load fresh components from Firestore
    final components = await loadCourseComponents(course.courseId);
    
    _selectedCourse = Course(
      courseId: course.courseId,
      userId: course.userId,
      courseName: course.courseName,
      courseCode: course.courseCode,
      units: course.units,
      instructor: course.instructor,
      academicYear: course.academicYear,
      semester: course.semester,
      gradingSystem: course.gradingSystem,
      components: components,
      grade: course.grade,
    );
    
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
  
  // CENTRALIZED GRADE CALCULATION
  Future<double> calculateCourseGrade({List<Component?>? components}) async {
    final courseComponents = components ?? _selectedCourse?.components ?? [];
    double totalGrade = 0.0;
    
    print("=== PROVIDER GRADE CALCULATION ===");
    print("Components found: ${courseComponents.length}");
    
    for (final component in courseComponents) {
      if (component == null) continue;
      
      // Get all records for this component from Firestore
      final recordsSnapshot = await FirebaseFirestore.instance
          .collection('records')
          .where('componentId', isEqualTo: component.componentId)
          .get();
      
      double totalScore = 0.0;
      double totalPossible = 0.0;
      
      print("\n--- Component: ${component.componentName} ---");
      print("Weight: ${component.weight.toStringAsFixed(2)}%");
      print("Records found: ${recordsSnapshot.docs.length}");
      
      for (final doc in recordsSnapshot.docs) {
        final record = Records.fromMap(doc.data());
        totalScore += record.score;
        totalPossible += record.total;
        
        print("  ${record.name}: ${record.score.toStringAsFixed(2)}/${record.total.toStringAsFixed(2)}");
      }
      
      if (totalPossible > 0) {
        double componentPercentage = (totalScore / totalPossible) * 100;
        double weightedScore = componentPercentage * (component.weight / 100);
        totalGrade += weightedScore;
        
        print("Total Score: ${totalScore.toStringAsFixed(2)}/${totalPossible.toStringAsFixed(2)} = ${componentPercentage.toStringAsFixed(2)}%");
        print("Weighted Score: ${componentPercentage.toStringAsFixed(2)}% × ${component.weight.toStringAsFixed(2)}% = ${weightedScore.toStringAsFixed(2)}");
      } else {
        print("No valid records found for this component");
      }
    }
    
    print("\n=== FINAL GRADE ===");
    print("Total Course Grade: ${totalGrade.toStringAsFixed(2)}%");
    print("========================\n");
    
    return double.parse(totalGrade.toStringAsFixed(2));
  }
  
  // UPDATE COURSE GRADE IN FIREBASE AND PROVIDER
  Future<void> updateCourseGrade({List<Component?>? components}) async {
    if (_selectedCourse == null) return;
    
    try {
      // Calculate new grade
      final newGrade = await calculateCourseGrade(components: components);
      
      // Update in Firebase
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourse!.courseId)
          .update({'grade': newGrade});
      
      // Update local state
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
        components: components ?? _selectedCourse!.components,
        grade: newGrade,
      );
      
      notifyListeners();
      print("Course grade updated to: ${newGrade.toStringAsFixed(2)}%");
      
    } catch (e) {
      print("Error updating course grade: $e");
    }
  }
  
  // ADD COMPONENT AND UPDATE GRADE
  Future<void> addComponentAndUpdateGrade(Component component) async {
    if (_selectedCourse == null) return;
    
    final updatedComponents = List<Component?>.from(_selectedCourse!.components)..add(component);
    await updateCourseGrade(components: updatedComponents);
  }
  
  // REMOVE COMPONENT AND UPDATE GRADE
  Future<void> removeComponentAndUpdateGrade(String componentId) async {
    if (_selectedCourse == null) return;
    
    try {
      // Remove component from local state
      final updatedComponents = _selectedCourse!.components
          .where((comp) => comp?.componentId != componentId)
          .toList();
      
      // Calculate new grade with remaining components
      final newGrade = await calculateCourseGrade(components: updatedComponents);
      
      // Update in Firebase
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourse!.courseId)
          .update({'grade': newGrade});
      
      // Update local state
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
        components: updatedComponents,
        grade: newGrade,
      );
      
      notifyListeners();
      print("Component removed and grade updated to: ${newGrade.toStringAsFixed(2)}%");
      
    } catch (e) {
      print("Error removing component and updating grade: $e");
    }
  }
  
  // Add method to load components from Firestore
  Future<List<Component>> loadCourseComponents(String courseId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('components')
        .where('courseId', isEqualTo: courseId)
        .get();
        
    return snapshot.docs
        .map((doc) => Component.fromMap(doc.data()))
        .toList();
  }
}