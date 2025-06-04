import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:gradecalculator/providers/auth_provider.dart';
import 'package:gradecalculator/screens/home_screen/homescreen.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TapGestureRecognizer forgotPasswordRecognizer = TapGestureRecognizer();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF6200EE)),
      ),

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.05),
                Text(
                  "Welcome back!",
                  style: GoogleFonts.poppins(
                    fontSize: size.height * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  "Please login to continue",
                  style: GoogleFonts.poppins(
                    fontSize: size.height * 0.02,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: height * 0.05),

                CustomTextFormField(
                  label: "Email",
                  controller: emailController,
                ),

                CustomTextFormField(
                  label: "Password",
                  controller: passwordController,
                  obscureText: true,
                ),

                SizedBox(height: size.height * 0.02),

                Text.rich(
                  TextSpan(
                    text: "Forgot Password?",
                    style: GoogleFonts.poppins(
                      color: Color(0xFF6200EE),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: forgotPasswordRecognizer..onTap = () {},
                  ),
                ),

                SizedBox(height: size.height * 0.06),

                SizedBox(
                  width: size.width * 0.8,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      String? result = await context
                          .read<AuthProvider>()
                          .signIn(email, password);

                      if (context.mounted) Navigator.pop(context);

                      if (result != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(result)));
                      } else {
                        // Success: Go to homescreen
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const Homescreen(),
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6200EE),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),

                    child: Text(
                      "Log In",
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.020,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: size.height * 0.018,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: size.height * 0.016,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6200EE), width: 2),
        ),
      ),
    );
  }
}
