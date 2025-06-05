import 'package:flutter/material.dart';

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(


      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        
      ),
      body: Center(
        child: Text(
          'Add Course Screen',
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),


    );
  }
}