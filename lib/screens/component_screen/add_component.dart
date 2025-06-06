import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradecalculator/components/custom_text_form_field.dart';

import 'package:gradecalculator/models/records.dart';
import 'package:gradecalculator/models/components.dart';
import 'package:gradecalculator/models/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:gradecalculator/providers/course_provider.dart';

class AddComponent extends StatefulWidget {
  const AddComponent({super.key});

  @override
  State<AddComponent> createState() => _AddComponentState();
}

class _AddComponentState extends State<AddComponent> {
  final TextEditingController componentNameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Change this to store actual Records objects
  final List<Records> records = [];
  final Map<String, TextEditingController> nameControllers = {};
  final Map<String, TextEditingController> scoreControllers = {};
  final Map<String, TextEditingController> totalControllers = {};

  @override
  void initState() {
    super.initState();
    _addRecord(); // Add initial record
  }

  // Add this debug function
  void _debugPrintRecords(String action) {
    print("=== DEBUG: Records $action ===");
    print("Total Records Count: ${records.length}");

    if (records.isEmpty) {
      print("No records found.");
    } else {
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        final recordId = record.recordId;

        // Get current values from controllers
        final name = nameControllers[recordId]?.text ?? '';
        final score = scoreControllers[recordId]?.text ?? '';
        final total = totalControllers[recordId]?.text ?? '';

        print("Record $i:");
        print("  - ID: $recordId");
        print("  - Name: '$name'");
        print("  - Score: '$score'");
        print("  - Total: '$total'");
        print("  - Component ID: '${record.componentId}'");
      }
    }
    print("========================\n");
  }

  void _addRecord() {
    setState(() {
      final recordId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new Records instance
      final newRecord = Records(
        recordId: recordId,
        componentId: '', // This will be set when component is saved
        name: '',
        score: 0.0,
        total: 0.0,
      );

      records.add(newRecord);
      nameControllers[recordId] = TextEditingController();
      scoreControllers[recordId] = TextEditingController();
      totalControllers[recordId] = TextEditingController();

      // Debug print after adding
      _debugPrintRecords("ADDED");
    });
  }

  void _removeRecord(int index) {
    setState(() {
      final recordId = records[index].recordId;

      // Debug print before removing
      print("=== DEBUG: REMOVING Record at index $index ===");
      print("Record ID to remove: $recordId");

      nameControllers[recordId]?.dispose();
      scoreControllers[recordId]?.dispose();
      totalControllers[recordId]?.dispose();
      nameControllers.remove(recordId);
      scoreControllers.remove(recordId);
      totalControllers.remove(recordId);
      records.removeAt(index);

      // Debug print after removing
      _debugPrintRecords("REMOVED");
    });
  }

  // Method to convert controllers data to Records objects
  List<Records> _getRecordsFromControllers() {
    return records.map((record) {
      final recordId = record.recordId;
      return Records(
        recordId: recordId,
        componentId: record.componentId, // Will be set when saving component
        name: nameControllers[recordId]?.text ?? '',
        score: double.tryParse(scoreControllers[recordId]?.text ?? '0') ?? 0.0,
        total: double.tryParse(totalControllers[recordId]?.text ?? '0') ?? 0.0,
      );
    }).toList();
  }

  // Add this method to save component and records to Firebase
  Future<void> _saveComponentToFirestore() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final selectedCourse = courseProvider.selectedCourse;
    
    if (selectedCourse == null) {
      print("No course selected");
      return;
    }

    try {
      // Create component document reference
      final componentDocRef = FirebaseFirestore.instance.collection('components').doc();
      final componentId = componentDocRef.id;

      // Create the component (WITHOUT records list since we store them separately)
      final component = Component(
        componentId: componentId,
        componentName: componentNameController.text,
        weight: double.tryParse(weightController.text) ?? 0.0,
        courseId: selectedCourse.courseId,
        records: [], // Empty list since records are stored in separate collection
      );

      // Save component to Firebase
      await componentDocRef.set(component.toMap());

      // Create a batch to save all records at once
      final batch = FirebaseFirestore.instance.batch();
      
      // Save each record to the records collection
      for (final record in records) {
        final recordId = record.recordId;
        final recordDocRef = FirebaseFirestore.instance.collection('records').doc(recordId);
        
        final recordData = Records(
          recordId: recordId,
          componentId: componentId, // Reference to the component
          name: nameControllers[recordId]?.text ?? '',
          score: double.tryParse(scoreControllers[recordId]?.text ?? '0') ?? 0.0,
          total: double.tryParse(totalControllers[recordId]?.text ?? '0') ?? 0.0,
        );
        
        // Add to batch
        batch.set(recordDocRef, recordData.toMap());
      }
      
      // Commit all record saves in one transaction
      await batch.commit();

      // Update the course document to include this component
      final courseDocRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(selectedCourse.courseId);

      await courseDocRef.update({
        'components': FieldValue.arrayUnion([component.toMap()])
      });

      // Update the selected course in provider with the new component
      final updatedComponents = List<Component?>.from(selectedCourse.components)
        ..add(component);

      final updatedCourse = Course(
        courseId: selectedCourse.courseId,
        userId: selectedCourse.userId,
        courseName: selectedCourse.courseName,
        courseCode: selectedCourse.courseCode,
        units: selectedCourse.units,
        instructor: selectedCourse.instructor,
        academicYear: selectedCourse.academicYear,
        semester: selectedCourse.semester,
        gradingSystem: selectedCourse.gradingSystem,
        components: updatedComponents,
        grade: selectedCourse.grade,
      );

      courseProvider.updateSelectedCourse(updatedCourse);

      print("Component saved successfully!");
      print("${records.length} records saved to records collection!");
      
    } catch (e) {
      print("Error saving component: $e");
      // You might want to show an error dialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: height * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: "ADD A  "),
                      TextSpan(
                        text: "COMPONENT.",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6200EE),
                          fontWeight: FontWeight.bold,
                          fontSize: height * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),
                CustField(
                  label: "Component",
                  hintText: "Assignments",
                  icon: Icons.list_alt,
                  controller: componentNameController,
                ),
                SizedBox(height: height * 0.015),
                CustField(
                  label: "Weight (%)",
                  hintText: "10%",
                  icon: Icons.assignment,
                  controller: weightController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: height * 0.025),
                _buildRecordsSystem(height),
                SizedBox(height: height * 0.015),
                Center(
                  child: SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate input
                        if (componentNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter component name')),
                          );
                          return;
                        }
                        
                        if (weightController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter component weight')),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        
                        await _saveComponentToFirestore();
                        
                        if (mounted) {
                          Navigator.of(context).pop(); // Close the loading dialog
                          Navigator.of(context).pop(); // Go back to CourseInfo
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EE),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        "Add Component",
                        style: GoogleFonts.poppins(
                          fontSize: size.height * 0.020,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsSystem(double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Records",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: height * 0.02,
          ),
        ),
        SizedBox(height: height * 0.01),
        _buildRecordsTableHeader(height),
        _buildRecordsTableRows(height),
      ],
    );
  }

  Widget _buildRecordsTableHeader(double height) {
    return Container(
      padding: EdgeInsets.all(height * 0.015),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Name",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: height * 0.018,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Score",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: height * 0.018,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Total",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: height * 0.018,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: height * 0.05),
        ],
      ),
    );
  }

  Widget _buildRecordsTableRows(double height) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            return _buildRecordRow(record, index, height);
          }),
          _buildAddButton(height),
        ],
      ),
    );
  }

  Widget _buildRecordRow(Records record, int index, double height) {
    final recordId = record.recordId;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: height * 0.015,
        vertical: height * 0.01,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildTextField(
              controller: nameControllers[recordId]!,
              height: height,
              keyboardType: TextInputType.text,
            ),
          ),
          _buildSeparator(" ", height),
          Expanded(
            flex: 2,
            child: _buildTextField(
              controller: scoreControllers[recordId]!,
              height: height,
              keyboardType: TextInputType.number,
            ),
          ),
          _buildSeparator(" ", height),
          Expanded(
            flex: 2,
            child: _buildTextField(
              controller: totalControllers[recordId]!,
              height: height,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(width: height * 0.01),
          _buildDeleteButton(index, height),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required double height,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: height * 0.018),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: height * 0.01,
          vertical: height * 0.01,
        ),
      ),
    );
  }

  Widget _buildSeparator(String text, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: height * 0.01),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: height * 0.02,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(int index, double height) {
    return SizedBox(
      width: height * 0.05,
      child: records.length > 1
          ? IconButton(
              onPressed: () => _removeRecord(index),
              icon: Icon(
                Icons.delete,
                color: const Color(0xFFCF6C79),
                size: height * 0.025,
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildAddButton(double height) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(height * 0.01),
      child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          onPressed: _addRecord,
          icon: Icon(
            Icons.add_circle,
            color: const Color(0xFF6200EE),
            size: height * 0.04,
          ),
        ),
      ),
    );
  }

  // Method to save the component with records
  void _saveComponent() {
    final recordsList = _getRecordsFromControllers();

    // Here you would typically save to your database
    // Example:
    // final component = Component(
    //   componentName: componentNameController.text,
    //   weight: double.tryParse(weightController.text) ?? 0.0,
    //   records: recordsList,
    // );

    print("Component Name: ${componentNameController.text}");
    print("Weight: ${weightController.text}");
    print("Records: ${recordsList.map((r) => r.toMap()).toList()}");
  }
}
