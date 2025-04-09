import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trekverse/pages/package_detail.dart';

class ShowPackage extends StatefulWidget {
  const ShowPackage({super.key});

  @override
  State<ShowPackage> createState() => _ShowPackageState();
}

class _ShowPackageState extends State<ShowPackage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Color(0xFF4CAF50),
        title: Text(
          'Packages',
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
          color: isDarkMode ? Color(0xFF81C784) : Colors.white,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5F7),
        ),
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('brands')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No data Found'),
                  ),
                );
              }
              final brandDocs = snapshot.data!.docs;
              return Padding(
                padding: EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: brandDocs.length,
                  itemBuilder: (context, index) {
                    final brandData = brandDocs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetail(Packages: brandDocs[index]),
                          ),
                        );
                      },
                      child: Card(
                        color: isDarkMode
                            ? Color(0xFF2E7D32).withOpacity(0.5)
                            : Color(0xFFA5D6A7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 10.0, left: 10.0, top: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black54
                                          : Colors.grey.withOpacity(0.5),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    brandData['imageUrl'],
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(
                                          Icons.hide_image,
                                          size: 80,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      brandData['name'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Color(0xFF81C784)
                                            : Color(0xFF344C64),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      brandData['description'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        color: isDarkMode
                                            ? Color(0xFFFFFFFF)
                                            : Color(0xFF344C64),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.devices,
                                          size: 15,
                                          color: isDarkMode
                                              ? Color(0xFFB9774D)
                                              : Color(0xFFB9774D),
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            brandData['platform'],
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Color(0xFFB9774D)
                                                  : Color(0xFFB9774D),
                                            ),
                                            maxLines: 1,
                                          ),
                                        )
                                      ],
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
        ),
      ),
    );
  }
}
