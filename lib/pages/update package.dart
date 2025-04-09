import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class UpdatePackage extends StatefulWidget {
  const UpdatePackage({super.key});

  @override
  State<UpdatePackage> createState() => _UpdatePackageState();
}

class _UpdatePackageState extends State<UpdatePackage> {
  bool _isHovered = false;
  bool _isClicked = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedBrandId;
  Map<String, dynamic>? _selectedBranddata;
  List<QueryDocumentSnapshot> brands = [];
  late TextEditingController _nameController;
  late TextEditingController _platformController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  late TextEditingController _countryController;
  File? _selectedImage;
  bool isUploading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _platformController = TextEditingController();
    _descriptionController = TextEditingController();
    _urlController = TextEditingController();
    _countryController = TextEditingController();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('brands').get();
      setState(() {
        brands = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _onBrandSelected(String? brandId) async {
    if (brandId != null) {
      final selectedBrand = brands.firstWhere((brand) => brand.id == brandId).data();
      setState(() {
        _selectedBrandId = brandId;
        _selectedBranddata = selectedBrand as Map<String, dynamic>;
        _nameController.text = _selectedBranddata!['name'] ?? '';
        _descriptionController.text = _selectedBranddata!['description'] ?? '';
        _countryController.text = _selectedBranddata!['country'] ?? '';
        _platformController.text = _selectedBranddata!['platform'] ?? '';
        _urlController.text = _selectedBranddata!['url'] ?? '';
      });

      // Fetch image URL
      String? imageUrl = _selectedBranddata!['imageUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        File? tempImage = await _downloadAndSaveImage(imageUrl);
        if (tempImage != null) {
          setState(() {
            _selectedImage = tempImage;
          });
        }
      }
    }
  }
  Future<File?> _downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/temp_image.jpg');
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
        _selectedImage = File(pickedFile.path);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Upload")));
      return null;
    }
  }

  Future<void> _updateBrand() async {
    final name = _nameController.text.trim();
    final platform = _platformController.text.trim();
    final description = _descriptionController.text.trim();
    final url = _urlController.text.trim();
    final country = _countryController.text.trim();

    if (name.isEmpty || description.isEmpty || url.isEmpty || platform.isEmpty || country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Fill the Details Properly")));
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String? imageUrl = _selectedBranddata?['imageUrl'];
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      }

      final brandData = {
        'name': name,
        'platform': platform,
        'description': description,
        'url': url,
        'country': country,
        'imageUrl': imageUrl ?? _selectedBranddata?['imageUrl'],
        'updatedAt': FieldValue.serverTimestamp()
      };

      await _firestore.collection('brands').doc(_selectedBrandId).update(brandData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Package Updated")));
      Navigator.pop(context);
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
          'Update Package',
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.95, // 80% of screen width
                child: DropdownButtonFormField<String>(
                  value: _selectedBrandId,
                  isExpanded: true, // Prevents text overflow
                  decoration: InputDecoration(
                    isDense: true, // Reduces extra padding
                    filled: true,
                    fillColor: isDarkMode ? Color(0xFF2E7D32).withOpacity(0.4) : Color(0xFF4CAF50).withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0), // Adjust padding
                  ),
                  hint: Text(
                    'Select Brand',
                    style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                  ),
                  onChanged: _onBrandSelected,
                  items: brands.map((brand) {
                    return DropdownMenuItem<String>(
                      value: brand.id,
                      child: Text(
                        brand['name'],
                        style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                        overflow: TextOverflow.ellipsis, // Truncates text if too long
                      ),
                    );
                  }).toList(),
                ),
              ),


              SizedBox(height: 16),

              GestureDetector(
                onTap: _showImagePickerOption,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                    color: isDarkMode ? Color(0xFF2E7D32).withOpacity(0.4) : Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                  ),

                  child: _selectedImage == null
                      ? Icon(Icons.add_a_photo, size: 50, color: isDarkMode ? Colors.white : Color(0xFF344C64))
                      : null,
                ),
              ),
              SizedBox(height: 16),

              buildTextField(_nameController, Icons.text_fields, 'Name'),
              buildTextField(_platformController, Icons.devices, 'Platform'),
              buildTextField(_descriptionController, Icons.description, 'Description'),
              buildTextField(_urlController, Icons.link, 'URL'),
              buildTextField(_countryController, Icons.flag, 'Country'),
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
                      onPressed: isUploading ? null : _updateBrand,
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
                        "Update Package",
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              color: _isClicked
                                  ? Color(0xFF4CAF50)
                                  : const Color(0xFFFFFFFF),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
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
