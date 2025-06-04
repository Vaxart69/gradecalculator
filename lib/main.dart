import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
<<<<<<< Updated upstream
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
=======
import 'package:flutter/services.dart';

void main() {
  runApp(const GradeCalculator());
}

class GradeCalculator extends StatelessWidget {
  const GradeCalculator({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF121212), 
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grade Calculator',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        
        textTheme: GoogleFonts.poppinsTextTheme(
          
        )
>>>>>>> Stashed changes
      ),
    ),
  );
}