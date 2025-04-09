import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trekverse/pages/LogIn.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool _isHovered = false;
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Color(0xFF4CAF50), Color(0xFF121212)]
                : [Color(0xFFA5D6A7), Color(0xFFF4F5F7)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("Image/OB.png", height: 500, width: 500),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Step Beyond the Ordinary,",
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                    fontSize: 27.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "with Trekverse Leading You to Extraordinary Heights.",
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      if (!_isClicked) {
                        _isHovered = true;
                      }
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      if (!_isClicked) {
                        _isHovered = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isClicked = !_isClicked;
                          _isHovered = false;
                        });
                        _navigateWithLoading(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDarkMode ? Color(0xFF4CAF50) : Color(0xFF4CAF50),
                        backgroundColor: _isClicked
                            ? (isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5F7))
                            : (_isHovered ? Color(0xFF4CAF50) : Color(0xFF4CAF50)),
                        side: BorderSide(
                            color: _isClicked
                                ? Color(0xFF4CAF50)
                                : Colors.transparent,
                            width: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      child: Text(
                        "Start",
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: _isClicked
                                ? (isDarkMode ? Color(0xFF4CAF50) : Color(0xFF4CAF50))
                                : (isDarkMode ? Colors.black : Colors.white),
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _navigateWithLoading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(color: Colors.greenAccent,),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    });
  }
}
