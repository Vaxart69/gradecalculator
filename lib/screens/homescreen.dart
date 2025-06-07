import 'package:flutter/material.dart';
import 'package:gradecalculator/providers/auth_provider.dart';
import 'package:gradecalculator/providers/course_provider.dart'; // Add this import
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;
import '../models/course.dart' as courseModel;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Color _getGradeColor(double grade) {
    if (grade == 5.0) {
      return Colors.red;
    } else if (grade == 4.0) {
      return Colors.orange;
    } else if (grade <= 3.0) {
      return const Color(0xFF2F6D5E);
    } else {
      return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final authProvider = context.read<AuthProvider>();
    final user = context.watch<AuthProvider>().appUser;

    return Scaffold(
      body: SafeArea(
        child:
            user == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('appusers')
                          .doc(user.userId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text("User data not found"));
                    }

                    final userData = model.User.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>,
                    );

                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.03),
                            _buildWelcomeSection(userData, height),
                            SizedBox(height: height * 0.02),
                            _buildCoursesStream(userData, height),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildWelcomeSection(model.User userData, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, ${userData.username}!',
          style: GoogleFonts.poppins(
            fontSize: height * 0.030,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: height * 0.038,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: [
              const TextSpan(text: 'Track your '),
              TextSpan(
                text: 'grades',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6200EE),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesStream(model.User userData, double height) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('courses')
              .where('userId', isEqualTo: userData.userId)
              .snapshots(),
      builder: (context, courseSnapshot) {
        if (courseSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!courseSnapshot.hasData || courseSnapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              SizedBox(height: height * 0.30), 
              Center(
                child: Text(
                  "No courses added yet.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: height * 0.020,
                  ),
                ),
              ),
            ],
          );
        }

        final courses = courseSnapshot.data!.docs;
        final width = MediaQuery.of(context).size.width; 
        return Column(
          children:
              courses.map((doc) {
                final course = courseModel.Course.fromMap(
                  doc.data() as Map<String, dynamic>,
                );
                return _buildCourseCard(
                  course,
                  height,
                  width,
                ); // Pass width parameter
              }).toList(),
        );
      },
    );
  }

  Widget _buildCourseCard(
    courseModel.Course course,
    double height,
    double width,
  ) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: height * 0.008),
      elevation: 4.0,
      shadowColor: Colors.black.withOpacity(1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Stack(
        children: [
          ListTile(
            onTap: () {
              // Set the selected course in provider
              Provider.of<CourseProvider>(
                context,
                listen: false,
              ).selectCourse(course);
            },
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.fromLTRB(
              height * 0.020,
              height * 0.010,
              height * 0.075,
              height * 0.010,
            ),
            title: Text(
              "${course.courseCode} - ${course.courseName}",
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: height * 0.018,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildCourseSubtitle(course, height),
          ),
          _buildActionButtons(height, width),
        ],
      ),
    );
  }

  Widget _buildCourseSubtitle(courseModel.Course course, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "A.Y. ${course.academicYear}, ${course.semester}",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: height * 0.014,
          ),
        ),
        SizedBox(height: height * 0.006),
        Row(
          children: [
            _buildGradeText(course, height),
            const Spacer(),
            Text(
              "${(double.tryParse(course.units) ?? 0.0).toStringAsFixed(1)} units",
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: height * 0.014,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradeText(courseModel.Course course, double height) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Grade: ",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.normal,
              fontSize: height * 0.014,
            ),
          ),
          TextSpan(
            text: course.numericalGrade != null
                ? course.numericalGrade!.toStringAsFixed(1) // Show numerical grade only
                : "No grade yet",
            style: GoogleFonts.poppins(
              color: course.numericalGrade != null
                  ? _getGradeColor(course.numericalGrade!) // Use numerical grade for color
                  : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: height * 0.014,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double height, width) {
    return Positioned(
      top: height * 0.005,
      right: height * 0.005,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(height * 0.037, 0),
            child: IconButton(
              icon: Icon(Icons.edit, size: height * 0.017),
              color: Colors.white30,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: height * 0.020,
                minHeight: height * 0.020,
              ),
              onPressed: () {
                // TODO: Edit logic
              },
              tooltip: 'Edit',
            ),
          ),

          SizedBox(width: width * 0.02),
          IconButton(
            icon: Icon(Icons.delete, size: height * 0.017),
            color: Colors.white30,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: height * 0.020,
              minHeight: height * 0.020,
            ),
            onPressed: () {
              // TODO: Delete logic
            },
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
