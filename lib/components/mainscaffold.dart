import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:gradecalculator/components/bottom_nar_bar.dart';
import 'package:gradecalculator/screens/homescreen.dart';
import 'package:gradecalculator/screens/course_screens/add_course.dart';
import 'package:gradecalculator/screens/course_screens/course_info.dart';
import 'package:gradecalculator/screens/about_screen/about.dart';
import 'package:gradecalculator/providers/course_provider.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex; // Add this parameter
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _pages = [
    Homescreen(),
    SizedBox.shrink(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set initial index
  }

  void _onTabSelected(int index) {
    if (index == 1) {
      // Add button pressed, push AddCourse with transition
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AddCourse(),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

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
    } else {
      // Clear selected course when navigating to other tabs
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      courseProvider.clearSelectedCourse();
      
      // Normal tab switching - this will hide CourseInfo and show the selected page
      setState(() {
        _previousIndex = _selectedIndex;
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Stack(
            children: [
              PageTransitionSwitcher(
                duration: const Duration(milliseconds: 350),
                reverse: _selectedIndex < _previousIndex,
                transitionBuilder: (child, animation, secondaryAnimation) {
                  bool slideFromRight = _selectedIndex > _previousIndex;
                  
                  final begin = slideFromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var slideTween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  var fadeTween = Tween(
                    begin: 0.0,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeIn));

                  return SlideTransition(
                    position: animation.drive(slideTween),
                    child: FadeTransition(
                      opacity: animation.drive(fadeTween),
                      child: child,
                    ),
                  );
                },
                child: _pages[_selectedIndex],
              ),
              // Animated CourseInfo overlay
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
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
                child: courseProvider.selectedCourse != null
                    ? const CourseInfo()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: _selectedIndex,
            onTabSelected: _onTabSelected,
          ),
        );
      },
    );
  }
}