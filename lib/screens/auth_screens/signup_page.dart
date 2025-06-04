import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0, // Optional: flat look
        iconTheme: IconThemeData(color: Color(0xFF6200EE)),
      ),
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: SingleChildScrollView( // Wrap with scroll view
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.05),
                Text(
                  "Create new\naccount",
                  style: GoogleFonts.poppins(
                    fontSize: size.height * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: height * 0.02),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        label: "First Name",
                        controller: firstNameController,
                      ),
                    ),
                    SizedBox(width: width * 0.05),
                    Expanded(
                      child: CustomTextFormField(
                        label: "Last Name",
                        controller: lastNameController,
                      ),
                    ),
                  ],
                ),

                CustomTextFormField(
                  label: "Username",
                  controller: usernameController,
                ),

                CustomTextFormField(label: "Email", controller: emailController),
                CustomTextFormField(
                  label: "Password",
                  controller: passwordController,
                  obscureText: true,
                ),

                CustomTextFormField(
                  label: "Confirm Password",
                  controller: confirmPasswordController,
                  obscureText: true,
                ),

                SizedBox(
                   
                    height: size.height * 0.06,
                  ),


                  

                SizedBox(
                  width: size.width * 0.8,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   PageRouteBuilder(
                      //     pageBuilder:
                      //         (context, animation, secondaryAnimation) =>
                      //             const LoginPage(),
                      //     transitionsBuilder: (
                      //       context,
                      //       animation,
                      //       secondaryAnimation,
                      //       child,
                      //     ) {
                      //       const begin = Offset(1.0, 0.0);
                      //       const end = Offset.zero;
                      //       const curve = Curves.easeInOut;

                      //       var tween = Tween(
                      //         begin: begin,
                      //         end: end,
                      //       ).chain(CurveTween(curve: curve));

                      //       return SlideTransition(
                      //         position: animation.drive(tween),
                      //         child: child,
                      //       );
                      //     },
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6200EE),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),

                  
                    child: Text(
                      "Sign Up",
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
