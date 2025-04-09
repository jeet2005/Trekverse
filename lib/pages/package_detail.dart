import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
class ProductDetail extends StatefulWidget {
  final QueryDocumentSnapshot Packages;
  ProductDetail({Key? key, required this.Packages});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  bool isWishlistSaved = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double userRating = 0;
  bool isExpanded = false;
  TextEditingController feedbackController = TextEditingController();

  void _checkWishlist() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final packageId = widget.Packages.id;

    final wishlistRef = _firestore.collection('users').doc(userId).collection('wishlist');
    final wishlistDoc = await wishlistRef.doc(packageId).get();

    setState(() {
      isWishlistSaved = wishlistDoc.exists;
    });
  }

  void _toggleWishlist() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final packageId = widget.Packages.id;
    final wishlistRef = _firestore.collection('users').doc(userId).collection('wishlist');

    if (isWishlistSaved) {
      await wishlistRef.doc(packageId).delete();
    } else {
      await wishlistRef.doc(packageId).set({
        'name': widget.Packages['name'],
        'imageUrl': widget.Packages['imageUrl'],
        'description': widget.Packages['description'],
      });
    }
    setState(() {
      isWishlistSaved = !isWishlistSaved;
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch URL: $url")),
        );
      }
    } catch (e) {
      print("Error launching URL: $e"); // Debugging log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid URL: $url")),
      );
    }
  }

  void _submitFeedback() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final brandId = widget.Packages.id;
    await _firestore.collection('packages').doc(brandId).collection('feedback').add({
      'userId': userId,
      'rating': userRating,
      'comment': feedbackController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    feedbackController.clear();
    setState(() {
      userRating = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Feedback submitted successfully!")),
    );
  }

  Future<File?> _saveImageTemporarily(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/package_image.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file; // Return saved file
      }
    } catch (e) {
      print("Error saving image: $e");
    }
    return null;
  }

  Future<void> _sharePackage() async {
    try {
      final package = widget.Packages.data() as Map<String, dynamic>;
      final imageUrl = package['imageUrl'];
      final name = package['name'];
      final country = package['country'];
      final description = package['description'];
      final url = package['url'];

      final String shareText = '''
🌟 *Discover Your Next Adventure!* 🌍✨  

🏕️ *$name* – A journey through *$country*  

📍 *Experience:* ${description.length > 200 ? description.substring(0, 200) + "..." : description}  

🚀 Ready to explore? Tap below for full details! 👇  
🔗 $url  

🙏 *Shared via TrekVerse – Your Gateway to Unforgettable Journeys!*💙
''';



      final File? imageFile = await _saveImageTemporarily(imageUrl);

      if (imageFile != null) {
        await Share.shareXFiles([XFile(imageFile.path)], text: shareText);
      } else {
        print("Error: Image not found");
      }
    } catch (e) {
      print("Error sharing package: $e");
    }
  }

  final GlobalKey _previewContainer = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    var brandData = widget.Packages.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          brandData['name'],
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Color(0xFF81C784) : Colors.white,
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _sharePackage,
              color: isDarkMode ? Color(0xFF81C784) : Colors.white
          ),
        ],
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: isDarkMode ? Color(0xFF81C784) : Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: Image.network(
                brandData['imageUrl'],
                height: 250,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 100,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          brandData['name'],
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Color(0xFF81C784) : Color(0xFF344C64),
                          ),
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isWishlistSaved ? Icons.favorite : Icons.favorite_border,
                          color: isWishlistSaved ? Colors.red : Colors.grey,
                        ),
                        onPressed: _toggleWishlist,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[300], thickness: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          brandData['country'],
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isExpanded ? brandData['description'] : '${brandData['description'].substring(0, 100)}...', // Show only part of the text initially
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: isExpanded ? null : 5, // Limit lines when not expanded
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),

                  if (!isExpanded)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.white, // Background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                            ),
                            title: Text(
                              "Full Description",
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Container(
                              constraints: BoxConstraints(maxHeight: 300), // Limit height
                              child: SingleChildScrollView(
                                child: Text(
                                  brandData['description'],
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: isDarkMode ? Color(0xFF4CAF50) : Color(0xFF388E3C), // Green button
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(
                                    "Close",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        "... Read More",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Color(0xFF81C784) : Colors.black87,
                        ),
                      ),
                    ),

                  const SizedBox(height: 50),
            SizedBox(
            width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {  // Make it async for better error handling
                  String platformUrl = (brandData['url'] ?? '').trim(); // Trim spaces

                  if (platformUrl.isNotEmpty) {
                    if (!platformUrl.startsWith('http://') && !platformUrl.startsWith('https://')) {
                      platformUrl = 'https://' + platformUrl;
                    }

                    await _launchURL(platformUrl); // Await to catch any errors
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No valid URL found")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Book on ${brandData['platform']}',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    "Rate this Package",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30,  // Increase size for better visibility
                    glow: true,
                    unratedColor: Colors.grey.shade300,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        userRating = rating;
                      });
                    },
                  ),

                  SizedBox(height: 10),
                  TextField(
                    controller: feedbackController,
                    decoration: InputDecoration(
                      hintText: "Write your feedback here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Submit Feedback",
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 30),
                  Text(
                    "Recent comments...",
                    style: GoogleFonts.nunito(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StreamBuilder(
                    stream: _firestore
                        .collection('packages')
                        .doc(widget.Packages.id) // Fetching using the correct brand ID
                        .collection('feedback')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: _firestore.collection('user').doc(doc['userId']).get(),
                            builder: (context, userSnapshot) {
                              String userName = "Anonymous";
                              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                userName = userSnapshot.data!.get('name');
                              }

                              return ListTile(
                                title: Text(userName, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingBarIndicator(
                                      rating: (doc['rating'] as num).toDouble(),
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 16.0,
                                    ),
                                    Text(doc['comment'] ?? "No comment"),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
