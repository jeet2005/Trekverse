import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddNews extends StatefulWidget {
  const AddNews({super.key});

  @override
  State<AddNews> createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  bool _isHovered = false;
  bool _isClicked = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  File? _selectedImage;
  bool isUploading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void showImagePickerOption() {
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
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            )
          ],
        ),
      ),
    );
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Upload")));
      return null;
    }
  }

  Future<void> addNews() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final author = _authorController.text.trim();

    if (name.isEmpty || description.isEmpty || author.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Fill the Details Properly")));
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final imageUrl = await uploadImageToCloudinary(_selectedImage!);
      if (imageUrl == null) return;
      final newsData = {
        'name': name,
        'description': description,
        'author': author,
        'photo': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('news').add(newsData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("News Added")));
      _nameController.clear();
      _descriptionController.clear();
      _authorController.clear();
      setState(() {
        _selectedImage = null;
      });
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
          'Add News',
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Color(0xFF81C784) : Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: isDarkMode ? Color(0xFF81C784) : Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: showImagePickerOption,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: isDarkMode ? Colors.white : Color(0xFF344C64)),

                    color: isDarkMode ? Color(0xFF2E7D32).withOpacity(0.4) : Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    image: _selectedImage != null
                        ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Icon(Icons.add_a_photo, size: 50, color: isDarkMode ? Colors.white : Color(0xFF344C64))
                      : null,
                ),
              ),
              SizedBox(height: 16),
              buildTextField(_nameController, Icons.text_fields, 'Name'),
              buildTextField(_descriptionController, Icons.description, 'Description'),
              buildTextField(_authorController, Icons.person, 'Author'),
              SizedBox(height: 16),
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
                      onPressed: isUploading ? null : () async {
                        await addNews();
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
                            ? Color(0xFFF4F5F7)
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
                      child: isUploading
                          ? CircularProgressIndicator()
                          : Text(
                        "Add News",
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              color: _isClicked
                                  ? Color(0xFF4CAF50)
                                  : const Color(0xFFFFFFFF),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
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
    );
  }

  Widget buildTextField(TextEditingController controller, IconData icon, String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
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
