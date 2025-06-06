import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradecalculator/components/custom_text_form_field.dart';
import 'package:gradecalculator/components/mainscaffold.dart';
import 'package:gradecalculator/models/course.dart';
import 'package:gradecalculator/models/grade_range.dart';
import 'package:gradecalculator/models/grading_system.dart';
import 'package:provider/provider.dart';
import 'package:gradecalculator/providers/auth_provider.dart';

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  String? selectedSemester;
  final List<String> semesters = ['1st Semester', '2nd Semester', 'Midyear'];

  // Controllers for course fields
  final courseCodeController = TextEditingController();
  final courseNameController = TextEditingController();
  final academicYearController = TextEditingController();
  final unitsController = TextEditingController();
  final instructorController = TextEditingController();

  // Grade range models and controllers
  final List<GradeRange> gradeRanges = [];
  final Map<String, TextEditingController> minControllers = {};
  final Map<String, TextEditingController> maxControllers = {};
  final Map<String, TextEditingController> gradeControllers = {};

  @override
  void initState() {
    super.initState();
    _addGradeRange();
  }

  void _printGradeRangesDebug() {
    print('--- Current Grade Ranges ---');
    for (var range in gradeRanges) {
      final min = minControllers[range.rangeId]?.text ?? '';
      final max = maxControllers[range.rangeId]?.text ?? '';
      final grade = gradeControllers[range.rangeId]?.text ?? '';
      print(
        'RangeId: ${range.rangeId} | Min: $min | Max: $max | Grade: $grade | GradingSystemId: ${range.gradingSystemId}',
      );
    }
    print('----------------------------');
  }

  void _addGradeRange({String? gradingSystemId}) {
    setState(() {
      final rangeId = DateTime.now().millisecondsSinceEpoch.toString();
      final newRange = GradeRange(
        rangeId: rangeId,
        gradingSystemId: gradingSystemId ?? '',
        min: 0,
        max: 100,
        grade: 0.0,
      );
      gradeRanges.add(newRange);
      minControllers[rangeId] = TextEditingController();
      maxControllers[rangeId] = TextEditingController();
      gradeControllers[rangeId] = TextEditingController();
      _printGradeRangesDebug();
    });
  }

  void _removeGradeRange(int index) {
    setState(() {
      final rangeId = gradeRanges[index].rangeId;
      minControllers[rangeId]?.dispose();
      maxControllers[rangeId]?.dispose();
      gradeControllers[rangeId]?.dispose();
      minControllers.remove(rangeId);
      maxControllers.remove(rangeId);
      gradeControllers.remove(rangeId);
      gradeRanges.removeAt(index);
      _printGradeRangesDebug();
    });
  }

  Future<void> _saveCourseToFirestore() async {
    final docRef = FirebaseFirestore.instance.collection('courses').doc();
    final courseId = docRef.id;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.appUser?.userId ?? '';

    final updatedGradeRanges =
        gradeRanges
            .map(
              (range) => GradeRange(
                rangeId: range.rangeId,
                gradingSystemId: courseId,
                min:
                    int.tryParse(minControllers[range.rangeId]?.text ?? '') ??
                    0,
                max:
                    int.tryParse(maxControllers[range.rangeId]?.text ?? '') ??
                    0,
                grade:
                    double.tryParse(
                      gradeControllers[range.rangeId]?.text ?? '',
                    ) ??
                    0.0,
              ),
            )
            .toList();

    final gradingSystem = GradingSystem(
      gradingSystemId: courseId,
      courseId: courseId,
      gradeRanges: updatedGradeRanges,
    );

    final course = Course(
  courseId: courseId,
  userId: userId,
  courseName: courseNameController.text,
  courseCode: courseCodeController.text,
  units: unitsController.text,
  instructor: instructorController.text,
  academicYear: academicYearController.text,
  semester: selectedSemester ?? '',
  gradingSystem: gradingSystem,
  components: [],
);

    await docRef.set(course.toMap());

    final userDocRef = FirebaseFirestore.instance.collection('appusers').doc(userId);
  await userDocRef.update({
    'courses': FieldValue.arrayUnion([course.toMap()])
  });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(height),
                SizedBox(height: height * 0.02),
                _buildCourseFields(height),
                SizedBox(height: height * 0.025),
                _buildGradingSystem(height),
                SizedBox(height: height * 0.015),
                Center(
                  child: SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );
                        await _saveCourseToFirestore();
                        if (mounted) {
                          Navigator.of(
                            context,
                          ).pop(); // Close the loading dialog
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const MainScaffold(),
                            ),
                            (route) => false,
                          );
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
                        "Add Course",
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

  Widget _buildTitle(double height) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: height * 0.04,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        children: [
          const TextSpan(text: "ADD A  "),
          TextSpan(
            text: "COURSE.",
            style: GoogleFonts.poppins(
              color: const Color(0xFF6200EE),
              fontWeight: FontWeight.bold,
              fontSize: height * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseFields(double height) {
    return Column(
      children: [
        CustField(
          label: "Course Code",
          icon: Icons.article,
          hintText: "CMSC 23",
          controller: courseCodeController,
        ),
        SizedBox(height: height * 0.015),
        CustField(
          label: "Course Name",
          icon: Icons.menu_book,
          hintText: "Mobile Programming",
          controller: courseNameController,
        ),
        SizedBox(height: height * 0.015),
        CustField(
          label: "Academic Year",
          icon: Icons.calendar_month,
          hintText: "2024-2025",
          controller: academicYearController,
        ),
        SizedBox(height: height * 0.015),
        _buildSemesterDropdown(height),
        SizedBox(height: height * 0.015),
        CustField(
          label: "Units",
          icon: Icons.format_list_numbered,
          hintText: "3",
          controller: unitsController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: height * 0.015),
        CustField(
          label: "Instructor (optional)",
          icon: Icons.person,
          hintText: "Mx. Instructor",
          controller: instructorController,
        ),
      ],
    );
  }

  Widget _buildSemesterDropdown(double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Semester",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: height * 0.02,
          ),
        ),
        SizedBox(height: height * 0.005),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_month, color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6200EE), width: 2),
            ),
          ),
          dropdownColor: Colors.white,
          iconEnabledColor: Colors.black54,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: height * 0.018,
          ),
          value: selectedSemester,
          hint: Text(
            "1st Semester",
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.3),
              fontWeight: FontWeight.w500,
              fontSize: height * 0.018,
            ),
          ),
          items:
              semesters.map((semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(
                    semester,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: height * 0.018,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedSemester = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGradingSystem(double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Grading System (Numerical Only)",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: height * 0.02,
          ),
        ),
        SizedBox(height: height * 0.01),
        _buildGradingTableHeader(height),
        _buildGradingTableRows(height),
      ],
    );
  }

  Widget _buildGradingTableHeader(double height) {
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
              "From",
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
              "To",
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
              "Grade",
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

  Widget _buildGradingTableRows(double height) {
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
          ...gradeRanges.asMap().entries.map((entry) {
            final index = entry.key;
            final range = entry.value;
            return _buildGradeRangeRow(range, index, height);
          }),
          _buildAddButton(height),
        ],
      ),
    );
  }

  Widget _buildGradeRangeRow(GradeRange range, int index, double height) {
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
              controller: minControllers[range.rangeId]!,
              height: height,
            ),
          ),
          _buildSeparator("-", height),
          Expanded(
            flex: 2,
            child: _buildTextField(
              controller: maxControllers[range.rangeId]!,
              height: height,
            ),
          ),
          _buildSeparator("=", height),
          Expanded(
            flex: 2,
            child: _buildTextField(
              controller: gradeControllers[range.rangeId]!,
              height: height,
              isDecimal: true,
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
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
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
      child:
          gradeRanges.length > 1
              ? IconButton(
                onPressed: () => _removeGradeRange(index),
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
          onPressed: _addGradeRange,
          icon: Icon(
            Icons.add_circle,
            color: const Color(0xFF6200EE),
            size: height * 0.04,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    courseCodeController.dispose();
    courseNameController.dispose();
    academicYearController.dispose();
    unitsController.dispose();
    instructorController.dispose();
    for (final controller in minControllers.values) {
      controller.dispose();
    }
    for (final controller in maxControllers.values) {
      controller.dispose();
    }
    for (final controller in gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
