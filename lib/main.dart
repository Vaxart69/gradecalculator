import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'calculatorform.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ComponentProvider()..listenToComponents(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Grade Calculator',
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: Calculator(),
      ),
    ),
  );
}