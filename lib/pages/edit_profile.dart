import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;

  File? _profileImage;
  bool isUploading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        userId = user.uid;
        final snapshot = await _firestore.collection('user').doc(userId).get();
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            setState(() {
              _emailController.text = data['email'] ?? '';
              _nameController.text = data['name'] ?? '';
            });

            // Fetch and download profile image if available
            String? imageUrl = data['profileimage'];
            if (imageUrl != null && imageUrl.isNotEmpty) {
              File? tempImage = await _downloadAndSaveImage(imageUrl);
              if (tempImage != null) {
                setState(() {
                  _profileImage = tempImage;
                });
              }
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  Future<File?> _downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/profile_image.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
    return null;
  }


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/durvdhk1b/image/upload';
    const cloudinaryPreset = 'tekverse_profile';
    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = cloudinaryPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      return responseData['secure_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Upload Image")));
      return null;
    }
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadImageToCloudinary(_profileImage!);
      }

      final userData = {
        'name': name,
        'profileimage': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp()
      };

      await _firestore.collection('user').doc(userId).update(userData);

      if (password.isNotEmpty) {
        await _auth.currentUser?.updatePassword(password);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated Successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Color(0xFF4CAF50),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Color(0xFF81C784) : Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color:isDarkMode ? Color(0xFF81C784) : Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _showImagePickerOption,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                    image: _profileImage != null
                        ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _profileImage == null
                      ? Icon(Icons.add_a_photo, size: 50, color: isDarkMode ? Colors.white : Color(0xFF344C64))
                      : null,
                ),
              ),

              SizedBox(height: 16),
              buildTextField(_emailController, Icons.email, 'Email', readOnly: true),
              buildTextField(_nameController, Icons.person, 'Name'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isUploading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric( vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Update Profile",
                  style: GoogleFonts.nunito(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, IconData icon, String label,
      {bool isPassword = false, bool readOnly = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
          ),
          prefixIcon: Icon(icon, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
          filled: true,
          fillColor: isDarkMode ? Color(0xFF2E7D32).withOpacity(0.4) : Color(0xFF4CAF50).withOpacity(0.2),
        ),
      ),
    );
  }
}
