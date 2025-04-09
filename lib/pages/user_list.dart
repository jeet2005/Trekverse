import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> users = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> blockUser(String userId) async {
    try {
      await _firestore.collection('user').doc(userId).update({'status': 'blocked'});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User has been blocked!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _firestore.collection('user').doc(userId).update({'status': 'active'});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User has been reactivated!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildUserList() {
    return StreamBuilder(
      stream: _firestore.collection('user').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading users"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No users found"));
        }
        users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userId = user.id;
            final userData = user.data() as Map<String, dynamic>;
            final userStatus = userData['status'] ?? 'active';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: _buildUserCard(userData, userId, userStatus),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, String userId, String userStatus) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDarkMode ? Color(0xFF2E7D32).withOpacity(0.5) : Color(0xFFA5D6A7),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: 100.0,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: userData['profileimage'] != null
                    ? NetworkImage(userData['profileimage'])
                    : null,
                child: userData['profileimage'] == null ? Icon(Icons.person, size: 30) : null,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userData['name'] ?? 'Unknown User', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Color(0xFF344C64))),
                  SizedBox(height: 5),
                  Text('Email: ${userData['email'] ?? 'No Email'}', style: TextStyle(color: isDarkMode ? Colors.white : Color(0xFF344C64))),
                  Text('Status: ${userStatus == 'blocked' ? 'Blocked' : 'Active'}', style: TextStyle(color: userStatus == 'blocked' ? Colors.red : Colors.green)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(userStatus == 'blocked' ? Icons.lock_open : Icons.lock, color: userStatus == 'blocked' ? Colors.green : Colors.red),
              onPressed: () {
                if (userStatus == 'blocked') {
                  unblockUser(userId);
                } else {
                  blockUser(userId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            users = users.where((user) {
              final userData = user.data() as Map<String, dynamic>;
              return userData['name']?.toLowerCase().contains(value.toLowerCase()) ?? false;
            }).toList();
          });
        },
        style: TextStyle(color: isDarkMode ? Color(0xFFB0B0B0) : isDarkMode ? Colors.white : Color(0xFF344C64)),
        decoration: InputDecoration(
          hintText: 'Search user',
          hintStyle: TextStyle(color: isDarkMode ? Color(0xFFB0B0B0).withOpacity(0.6) : isDarkMode ? Colors.white : Color(0xFF344C64).withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: isDarkMode ? Color(0xFFB0B0B0) : isDarkMode ? Colors.white : Color(0xFF344C64)),
          filled: true,
          fillColor: isDarkMode ? Color(0xFF2E7D32).withOpacity(0.4) : Color(0xFF4CAF50).withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Color(0xFF4CAF50),
        title: Text(
          'User List',
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
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 10),
            Expanded(
              child: buildUserList(),
            ),
          ],
        ),
      ),
    );
  }
}
