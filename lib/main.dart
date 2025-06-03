import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradecalculator/screens/auth_screens/starting_page.dart';
import 'package:provider/provider.dart';

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
        
        textTheme: GoogleFonts.poppinsTextTheme(
          
        )
      ),

      home: StartingPage()

      
    );
  }
}