import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trekverse/pages/package_detail.dart';
import 'package:trekverse/pages/news_detail.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFF4CAF50),
        title: Text(
          'Search',
          style: GoogleFonts.nunito(
              fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? const Color(0xFF81C784) : Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search Packages or News",
                hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.black54),
                prefixIcon: Icon(Icons.search,
                    color: isDarkMode ? Colors.white : Colors.black54),
                filled: true,
                fillColor: isDarkMode
                    ? Color(0xFF2E7D32).withOpacity(0.4)
                    : Color(0xFF4CAF50).withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_searchController.text.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Packages",
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              StreamBuilder(
                stream: _firestore.collection('brands').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No Packages Found'));
                  }

                  final packageDocs = snapshot.data!.docs;
                  final filteredPackageDocs = packageDocs.where((package) {
                    final query = _searchController.text.trim().toLowerCase();
                    final name = package['name']?.toString().toLowerCase() ?? '';
                    final description = package['description']?.toString().toLowerCase() ?? '';
                    final country = package['country']?.toString().toLowerCase() ?? '';
                    final platform = package['platform']?.toString().toLowerCase() ?? '';
                    final url = package['url']?.toString().toLowerCase() ?? '';

                    return name.contains(query) ||
                        description.contains(query) ||
                        country.contains(query) ||
                        platform.contains(query) ||
                        url.contains(query);
                  }).toList();

                  if (filteredPackageDocs.isEmpty) {
                    return const Center(child: Text('No results found for Packages'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPackageDocs.length,
                    itemBuilder: (context, index) {
                      final package = filteredPackageDocs[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(Packages: package),
                            ),
                          );
                        },
                        child: Column(
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
                                      child: package['imageUrl'] != null
                                          ? Image.network(
                                        package['imageUrl'],
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      )
                                          : Icon(Icons.image, size: 50),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            package['name'],
                                            style: GoogleFonts.nunito(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF344C64),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            package['description'],
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
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "News",
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              StreamBuilder(
                stream: _firestore.collection('news').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No News Found'));
                  }

                  final newsDocs = snapshot.data!.docs;

                  final filteredNewsDocs = newsDocs.where((news) {
                    final query = _searchController.text.trim().toLowerCase();
                    final name = news['name']?.toString().toLowerCase() ?? '';
                    final description = news['description']?.toString().toLowerCase() ?? '';
                    final author = news['author']?.toString().toLowerCase() ?? '';

                    return name.contains(query) ||
                        description.contains(query) ||
                        author.contains(query);
                  }).toList();

                  if (filteredNewsDocs.isEmpty) {
                    return const Center(child: Text('No results found for News'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredNewsDocs.length,
                    itemBuilder: (context, index) {
                      final news = filteredNewsDocs[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetail(News: news),
                            ),
                          );
                        },
                        child: Column(
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
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ] else ...[
              const Center(child: Text('Search and plan your next adventure...'))
            ],
          ],
        ),
      ),
    );
  }
}
