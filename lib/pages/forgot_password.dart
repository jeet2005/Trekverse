import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _isHovered = false;
  bool _isClicked = false;
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Please check your inbox.'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

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
                ? [const Color(0xFF4CAF50), const Color(0xFF121212)]
                : [const Color(0xFFA5D6A7), const Color(0xFFF4F5F7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reset Your Password",
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFF344C64),
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter your email address below. We will send you a link to reset your password.",
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFF344C64),
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : const Color(0xFF344C64),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: (isDarkMode ? Colors.white : const Color(0xFF344C64))
                            .withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: isDarkMode ? Colors.white : const Color(0xFF344C64),
                      ),
                      filled: true,
                      fillColor: (isDarkMode ? Colors.white : const Color(0xFF344C64))
                          .withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          child: ElevatedButton(
                            onPressed: () {
                              resetPassword();
                              setState(() {
                                _isClicked = true;
                                _isHovered = false;
                              });
                              Future.delayed(const Duration(milliseconds: 250), () {
                                setState(() {
                                  _isClicked = false;
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color(0xFF4CAF50),
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
                              "Send Reset Email",
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      color: _isClicked
                                          ? Color(0xFF4CAF50)
                                          : (isDarkMode ? Colors.black : Colors.white),
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
