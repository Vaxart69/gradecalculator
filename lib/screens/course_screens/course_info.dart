import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradecalculator/providers/course_provider.dart';
import 'package:provider/provider.dart';
import 'package:gradecalculator/screens/component_screen/add_component.dart';

class CourseInfo extends StatefulWidget {
  const CourseInfo({super.key}); // Remove course parameter

  @override
  State<CourseInfo> createState() => _CourseInfoState();
}

class _CourseInfoState extends State<CourseInfo> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final course = courseProvider.selectedCourse;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Clear the selected course to hide CourseInfo
                Provider.of<CourseProvider>(context, listen: false)
                    .clearSelectedCourse();
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${course?.courseCode}",
                      style: GoogleFonts.poppins(
                        color: Color(0xFF6200EE),
                        fontWeight: FontWeight.w800,
                        fontSize: height * 0.04,
                      ),
                    ),
                    Text(
                      "${course?.courseName}",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: height * 0.024,
                      ),
                    ),
                    Text(
                      "${course?.instructor}",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: height * 0.018,
                      ),
                    ),
                    Text(
                      "${course?.grade?.toStringAsFixed(1) ?? '0.0'}%",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: height * 0.018,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddComponent(), // Replace with your actual AddComponent widget
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            backgroundColor: const Color(0xFF6200EE),
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Component',
          ),
        );
      },
    );
  }
}
