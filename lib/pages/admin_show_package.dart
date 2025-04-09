import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminShowPackage extends StatefulWidget {
  const AdminShowPackage({super.key});

  @override
  State<AdminShowPackage> createState() => _AdminShowPackageState();
}

class _AdminShowPackageState extends State<AdminShowPackage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deletebrands(String docId) async {
    try {
      await _firestore.collection('brands').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("brands item deleted successfully"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error deleting brands item: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Color(0xFF4CAF50),
        title: Text(
          'Posts',
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Color(0xFF81C784) : Colors.white),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('brands').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No data Found'),
              );
            }
            final brandsDocs = snapshot.data!.docs;

            return Padding(
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: brandsDocs.length,
                itemBuilder: (context, index) {
                  final brands = brandsDocs[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.transparent,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              brands['imageUrl'],
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  brands['name'],
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  brands['description'],
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
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: isDarkMode ? Colors.red : Colors.redAccent,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Delete Package"),
                                    content: Text("Are you sure you want to delete this Package item?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deletebrands(brands.id);
                                          Navigator.pop(context);
                                        },
                                        child: Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
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
    );
  }
}
