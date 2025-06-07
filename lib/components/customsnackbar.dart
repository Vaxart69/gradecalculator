import 'package:flutter/material.dart';

class CustomSnackbar extends StatelessWidget {
  final String text;

  const CustomSnackbar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double minSide = size.width < size.height ? size.width : size.height;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: minSide * 0.6, // 60% of the smaller side
          height: minSide * 0.6, // 60% of the smaller side
          padding: EdgeInsets.all(minSide * 0.06), // Padding is also proportional
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.92),
            borderRadius: BorderRadius.circular(minSide * 0.08), // Rounded corners
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: minSide * 0.045, // Responsive font size
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// Call this function to show the snackbar
void showCustomSnackbar(BuildContext context, String text, {Duration duration = const Duration(seconds: 2)}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => CustomSnackbar(text: text),
  );

  overlay.insert(entry);
  Future.delayed(duration, entry.remove);
}