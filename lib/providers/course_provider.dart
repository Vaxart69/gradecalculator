import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradecalculator/api/course_api.dart';
import 'package:gradecalculator/models/course.dart';
import 'package:gradecalculator/models/components.dart';
import 'package:gradecalculator/models/grade_range.dart';
import 'package:gradecalculator/models/records.dart';

class CourseProvider with ChangeNotifier {
  final CourseApi _courseApi = CourseApi();
  
  // Selected course state
  Course? _selectedCourse;
  
  // Getters
  Course? get selectedCourse => _selectedCourse;
  
  // Select a course (when user taps on course card)
  void selectCourse(Course course) {
    // Set course immediately for instant navigation
    _selectedCourse = course;
    notifyListeners(); // Trigger navigation immediately
    
    // Load components asynchronously in the background
    _loadComponentsInBackground(course);
  }

  Future<void> _loadComponentsInBackground(Course course) async {
    try {
      // Load fresh components with timeout
      final components = await loadCourseComponents(course.courseId);
      
      // Only update if this course is still selected
      if (_selectedCourse?.courseId == course.courseId) {
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
          numericalGrade: course.numericalGrade,
        );
        notifyListeners(); // Update UI once components are loaded
      }
    } catch (e) {
      print("Failed to load components (offline?): $e");
      // Keep the course selected with empty components for offline mode
      if (_selectedCourse?.courseId == course.courseId) {
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
          components: [], // Empty components when offline
          grade: course.grade,
          numericalGrade: course.numericalGrade,
        );
        notifyListeners();
      }
    }
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
  
  // CALCULATE NUMERICAL GRADE FROM PERCENTAGE
  double? calculateNumericalGrade(double percentage, List<GradeRange> gradeRanges) {
    // Round up if .5 or above, round down if below .5
    final int rounded = (percentage % 1 >= 0.5)
        ? percentage.ceil()
        : percentage.floor();

    print("=== NUMERICAL GRADE CALCULATION ===");
    print("Original Percentage: ${percentage.toStringAsFixed(2)}%");
    print("Rounded Percentage for range check: $rounded%");
    print("Available grade ranges: ${gradeRanges.length}");

    for (final range in gradeRanges) {
      print("Checking range: ${range.min}-${range.max} = ${range.grade}");
      if (rounded >= range.min && rounded <= range.max) {
        print("✓ Match found! $rounded% falls in range ${range.min}-${range.max}");
        print("Numerical Grade: ${range.grade}");
        print("===================================\n");
        return range.grade;
      } else {
        print("✗ No match: $rounded% not in ${range.min}-${range.max}");
      }
    }

    print("⚠️ WARNING: No grade range found for $rounded%");
    print("===================================\n");
    return null; // No matching range found
  }
  
  // UPDATE COURSE GRADE IN FIREBASE AND PROVIDER (Modified)
  Future<void> updateCourseGrade({List<Component?>? components}) async {
    if (_selectedCourse == null) return;
    
    try {
      // Calculate new percentage grade
      final newPercentageGrade = await calculateCourseGrade(components: components);
      
      // Calculate numerical grade from percentage
      final numericalGrade = calculateNumericalGrade(
        newPercentageGrade, 
        _selectedCourse!.gradingSystem.gradeRanges
      );
      
      // Debug print
      print("=== GRADE UPDATE SUMMARY ===");
      print("Percentage Grade: ${newPercentageGrade.toStringAsFixed(2)}%");
      print("Numerical Grade: ${numericalGrade ?? 'No matching range'}");
      print("============================\n");
      
      // Update in Firebase
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourse!.courseId)
          .update({
        'grade': newPercentageGrade,
        'numericalGrade': numericalGrade, // Add this line
      });
      
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
        grade: newPercentageGrade,
        numericalGrade: numericalGrade, // Add this line
      );
      
      notifyListeners();
      print("Course grades updated - Percentage: ${newPercentageGrade.toStringAsFixed(2)}%, Numerical: ${numericalGrade ?? 'None'}");
      
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
  
  // REMOVE COMPONENT AND UPDATE GRADE (Updated)
  Future<void> removeComponentAndUpdateGrade(String componentId) async {
    if (_selectedCourse == null) return;
    
    try {
      // Remove component from local state
      final updatedComponents = _selectedCourse!.components
          .where((comp) => comp?.componentId != componentId)
          .toList();
      
      // Calculate new percentage grade with remaining components
      final newPercentageGrade = await calculateCourseGrade(components: updatedComponents);
      
      // Calculate numerical grade from percentage
      final numericalGrade = calculateNumericalGrade(
        newPercentageGrade, 
        _selectedCourse!.gradingSystem.gradeRanges
      );
      
      // Debug print
      print("=== DELETE GRADE UPDATE SUMMARY ===");
      print("Percentage Grade: ${newPercentageGrade.toStringAsFixed(2)}%");
      print("Numerical Grade: ${numericalGrade ?? 'No matching range'}");
      print("===================================\n");
      
      // Update in Firebase
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourse!.courseId)
          .update({
        'grade': newPercentageGrade,
        'numericalGrade': numericalGrade,
      });
      
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
        grade: newPercentageGrade,
        numericalGrade: numericalGrade,
      );
      
      notifyListeners();
      print("Component removed and grades updated - Percentage: ${newPercentageGrade.toStringAsFixed(2)}%, Numerical: ${numericalGrade ?? 'None'}");
      
    } catch (e) {
      print("Error removing component and updating grade: $e");
    }
  }
  
  // Add method to load components from Firestore
  Future<List<Component>> loadCourseComponents(String courseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('components')
          .where('courseId', isEqualTo: courseId)
          .get()
          .timeout(const Duration(seconds: 10)); // Add timeout
          
      return snapshot.docs
          .map((doc) => Component.fromMap(doc.data()))
          .toList();
    } on TimeoutException {
      print("Loading components timed out - returning empty list");
      return [];
    } catch (e) {
      print("Error loading components (offline?): $e");
      return [];
    }
  }

  // Add this method to clear course when user navigates away completely
  void clearSelectedCourseOnNavigation() {
    // This can be called when user navigates to different main tabs
    _selectedCourse = null;
    notifyListeners();
  }
}