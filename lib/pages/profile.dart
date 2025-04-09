import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekverse/pages/LogIn.dart';
import 'package:trekverse/pages/Theme_setting.dart';
import 'package:trekverse/pages/edit_profile.dart';
import 'AboutUs.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username;
  String? useremail;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('useremail');
      await prefs.remove('profileImageUrl');

      await FirebaseAuth.instance.signOut();  // Ensure the user is signed out from Firebase Auth

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(currentUser.uid).get();
        setState(() {
          username = userDoc['name'];
          useremail = userDoc['email'];
          profileImageUrl = userDoc['profileimage'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user data: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Color(0xFF4CAF50),
        title: Text(
          'Profile',
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Color(0xFF81C784) : Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5F7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF4CAF50),
                  width: 4,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profileImageUrl!),
              ),
            )
                : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF4CAF50),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: isDarkMode ? Color(0xFFB0B0B0) : Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              username ?? 'Loading...',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Color(0xFF344C64),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              useremail ?? 'Loading...',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Color(0xFF344C64),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                    title: Text(
                      'Edit Profile',
                      style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette, color: Color(0xFF4CAF50)),
                    title: Text(
                      'Theme',
                      style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ThemeSettingsPage()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xFF4CAF50)),
                    title: Text(
                      'About Us',
                      style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutUs()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.nunito(color: Colors.red),
                    ),
                    onTap: () async {
                      logout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
