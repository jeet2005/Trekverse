import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trekverse/pages/SignUP.dart';
import 'package:trekverse/pages/bottom nav.dart';
import 'package:trekverse/pages/admin_login.dart';
import 'package:trekverse/pages/forgot_password.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isHovered = false;
  bool _isClicked = false;
  bool _isLoading = false;
  bool _passwordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String userId = userCredential.user!.uid;
      DocumentSnapshot userDocument =
      await _firestore.collection('user').doc(userId).get();
      if (!userDocument.exists) {
        throw Exception('Record not found');
      }
      Map<String, dynamic> userData =
      userDocument.data() as Map<String, dynamic>;
      String userStatus = userData['status'] ?? 'active';
      if (userStatus == 'blocked') {
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your account is blocked.')),
        );
        return;
      }
      Navigator.of(context).pushReplacement(_createRoute(BottomNav()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [Color(0xFF4CAF50), Color(0xFF121212)]
                    : [Color(0xFFA5D6A7), Color(0xFFF4F5F7)],
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
                        "Welcome Back!",
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Color(0xFF344C64),
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login to your account",
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Color(0xFF344C64),
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.email,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock,
                        obscureText: !_passwordVisible,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPassword()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Color(0xFF344C64),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
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
                                login();
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
                                "Log In",
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

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Color(0xFF344C64),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUp()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                  color: isDarkMode ? Colors.white : Color(0xFF344C64),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminLogin()),
                          );
                        },
                        child: Center(
                          child: Text(
                            "Admin Login",
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                                color: isDarkMode ? Colors.white : Color(0xFF344C64),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    required bool isDarkMode,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Color(0xFF344C64),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: (isDarkMode ? Colors.white : Color(0xFF344C64)).withOpacity(0.6),
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? Colors.white : Color(0xFF344C64),
        ),
        filled: true,
        fillColor: (isDarkMode ? Colors.white : Color(0xFF344C64)).withOpacity(0.1),
        suffixIcon: icon == Icons.lock
            ? IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: isDarkMode ? Colors.white : Color(0xFF344C64),
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
