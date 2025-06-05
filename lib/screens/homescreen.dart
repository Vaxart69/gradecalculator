import 'package:flutter/material.dart';
import 'package:gradecalculator/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final authProvider = context.read<AuthProvider>();
    final user = context.watch<AuthProvider>().appUser;

    return Scaffold(
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
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
                      snapshot.data!.data() as Map<String, dynamic>);

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.03),
                          Text(
                            'Hi, ${userData.username}!',
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
                          if (userData.courses.isEmpty) ...[
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
                            SizedBox(height: size.height * 0.3),
                            Center(
                              child: Text(
                                "There is a course saved.",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: size.height * 0.020,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
