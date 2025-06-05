import 'package:flutter/material.dart';
import 'package:gradecalculator/providers/auth_provider.dart';
import 'package:gradecalculator/screens/auth_screens/starting_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final user = context.watch<AuthProvider>().appUser;
    return Scaffold(
      
      body: SafeArea(
        child:
            user == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.01),
                        Text(
                          'Hi, ${user.username}!',
                          style: GoogleFonts.poppins(
                            fontSize: size.height * 0.030,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.038,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              const TextSpan(text: 'Track your '),
                              TextSpan(
                                text: 'grades',
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF6200EE),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (user.courses.isEmpty) ...[
                          SizedBox(height: size.height * 0.3),
                          Center(
                            child: Text(
                              "No saved courses yet.",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: size.height * 0.020,
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            "There is a course.",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: size.height * 0.020,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
