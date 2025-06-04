import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradecalculator/screens/auth_screens/starting_page.dart';

void main() {
  runApp(const GradeCalculator());
}

class GradeCalculator extends StatelessWidget {
  const GradeCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grade Calculator',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212), // Set global background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212), // AppBar background
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: StartingPage(),
    );
  }
}