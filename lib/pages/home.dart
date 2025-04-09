import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trekverse/pages/news_detail.dart';
import 'package:trekverse/pages/package_detail.dart';
import 'package:trekverse/pages/show_package.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? username;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserdata();
  }

  Future<void> fetchUserdata() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('user').doc(currentUser.uid).get();
        setState(() {
          username = userDoc['name'];
          profileImageUrl = userDoc['profileimage'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFF4CAF50),
        title: Text(
          'TrekVerse',
          style: GoogleFonts.nunito(
              fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? const Color(0xFF81C784) : Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F5F7),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hello, ${username ?? 'Loading...'}',
                        style: GoogleFonts.nunito(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(profileImageUrl!),
                      ),
                    )
                        : Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to TrekVerse.!',
                        style: GoogleFonts.nunito(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF344C64),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plan your Next Adventure',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ShowPackage()),
                        );
                      },
                      child: Icon(
                        Icons.arrow_forward,
                        size: 30,
                        color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('brands').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No data Found'),
                      );
                    }
                    final brandDocs = snapshot.data!.docs;

                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: brandDocs.length,
                        itemBuilder: (context, index) {
                          final brand = brandDocs[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetail(Packages: brandDocs[index]),
                                ),
                              );
                            },
                            child: Container(
                              width: 250,
                              margin: const EdgeInsets.only(right: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(brand['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: 40,
                                    left: 10,
                                    right: 10, // Added to respect container width
                                    child: Text(
                                      brand['name'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                            color: Colors.black.withOpacity(0.7),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1, // Ensures a single line
                                      overflow: TextOverflow.ellipsis, // Adds ellipsis
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    right: 10, // Added to respect container width
                                    child: Text(
                                      brand['country'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                            color: Colors.black.withOpacity(0.7),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),


                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top News!!',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream: _firestore.collection('news').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No data Found'),
                      );
                    }
                    final newsDocs = snapshot.data!.docs;

                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            final news = newsDocs[index];
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsDetail(News: newsDocs[index]),
                                    ),
                                  );
                                },
                            child:  Column(
                              children: [
                                Column(
                                  children: [
                                    Card(
                                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: Colors.transparent,
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                news['photo'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    news['name'],
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    news['description'],
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.normal,
                                                      color: isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF344C64),
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey[300],
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ));
                          },
                        ),
                        SizedBox(height: 50),

                        AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'Image/discount.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Follow Us on...',
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(AntDesign.facebook_square, size: 35, color: Colors.blue),
                                onPressed: () {
                                },
                              ),
                              IconButton(
                                icon: Icon(AntDesign.twitter, size: 35, color: Colors.blue),
                                onPressed: () {
                                },
                              ),
                              IconButton(
                                icon: Icon(AntDesign.instagram, size: 35, color: Colors.pink),
                                onPressed: () {
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}
