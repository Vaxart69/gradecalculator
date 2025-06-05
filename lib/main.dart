import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradecalculator/components/bottom_nar_bar.dart';
import 'package:gradecalculator/components/mainscaffold.dart';
import 'package:gradecalculator/screens/homescreen.dart';
import 'package:provider/provider.dart';
import 'package:gradecalculator/providers/auth_provider.dart';
import 'package:gradecalculator/screens/auth_screens/starting_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make navigation bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light, 
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.light, 
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grade Calculator',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (authProvider.appUser != null) {
      return MainScaffold();
    } else {
      return StartingPage();
    }
  },
),
    );
  }
}