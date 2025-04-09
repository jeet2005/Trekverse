import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trekverse/pages/LogIn.dart';
import 'package:trekverse/pages/admin_homepage.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _adminemailController = TextEditingController();
  final TextEditingController _adminpasswordController = TextEditingController();
  bool _isHovered = false;
  bool _isClicked = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<bool> validateAdmin(String email, String password) async {
    try {
      final QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (adminSnapshot.docs.isEmpty) return false;
      final adminData = adminSnapshot.docs.first.data() as Map<String, dynamic>;
      return adminData['password'] == password;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      return false;
    }
  }

  Future<void> loginAsAdmin() async {
    setState(() {
      _isLoading = true;
    });
    final email = _adminemailController.text.trim();
    final password = _adminpasswordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please Fill Data")));
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final isAdminValid = await validateAdmin(email, password);
      if (isAdminValid) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Welcome, Admin!")));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AdminHome()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Invalid Login")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                        "Hello Sir...!!!",
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
                        "Please Varify...",
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Color(0xFF344C64),
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      TextField(
                        controller: _adminemailController,
                        style: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: (isDarkMode ? Colors.white : Color(0xFF344C64)).withOpacity(0.6)),
                          prefixIcon: Icon(Icons.email, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                          filled: true,
                          fillColor: (isDarkMode ? Colors.white : Color(0xFF344C64)).withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _adminpasswordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: (isDarkMode ? Colors.white : Color(0xFF344C64)).withOpacity(0.6)),
                          prefixIcon: Icon(Icons.lock, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                          filled: true,
                          fillColor: (isDarkMode ? Colors.white : Color(0xFF344C64)).withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: isDarkMode ? Colors.white : Color(0xFF344C64),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
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
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                setState(() {
                                  _isClicked = true;
                                  _isHovered = false;
                                });
                                Future.delayed(const Duration(milliseconds: 250), () {
                                  setState(() {
                                    _isClicked = false;
                                  });
                                });
                                loginAsAdmin();
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

                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                        },
                        child: Center(
                          child: Text(
                            "Back to User Login",
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
          if (_isLoading)  // Loading overlay
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              ),
            ),
        ],
      ),
    );
  }
}
