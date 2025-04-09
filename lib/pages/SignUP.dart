import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trekverse/pages/LogIn.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isHovered = false;
  bool _isClicked = false;
  bool _isLoading = false;
  File? _image;
  bool _isPasswordVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      const cloudinaryUrl = "https://api.cloudinary.com/v1_1/durvdhk1b/image/upload";
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': 'tekverse_profile',
      });

      final response = await Dio().post(cloudinaryUrl, data: formData);
      return response.data['secure_url'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _register() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add your Profile Picture...")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String imageUrl = await _uploadImage(_image!);
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection('user').doc(userCredential.user!.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'profileimage': imageUrl,
        'password': _passwordController.text,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isClicked = false;
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
                        "Create Account",
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
                        "Sign up to get started",
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Color(0xFF344C64),
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Color(0xFF344C64).withOpacity(0.1),
                            backgroundImage: _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? Icon(Icons.camera_alt, color: isDarkMode ? Colors.white : Color(0xFF344C64))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Color(0xFF344C64).withOpacity(0.6)),
                          prefixIcon: Icon(Icons.person, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Color(0xFF344C64).withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Color(0xFF344C64).withOpacity(0.6)),
                          prefixIcon: Icon(Icons.email, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Color(0xFF344C64).withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Color(0xFF344C64).withOpacity(0.6)),
                          prefixIcon: Icon(Icons.lock, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Color(0xFF344C64).withOpacity(0.1),
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
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color(0xFF4CAF50),
                                backgroundColor: _isClicked
                                    ? (isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5F7))
                                    : (_isHovered ? Color(0xFF4CAF50) : Color(0xFF4CAF50)),
                                side: BorderSide(
                                  color: _isClicked ? Color(0xFF4CAF50) : Colors.transparent,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    color: _isClicked
                                        ? Color(0xFF4CAF50)
                                        : (isDarkMode ? Colors.black : Colors.white),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                            "Already have an account? ",
                            style: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                            },
                            child: Text(
                              'Login',
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
