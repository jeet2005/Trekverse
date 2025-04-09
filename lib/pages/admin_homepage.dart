import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:trekverse/pages/Theme_setting.dart';
import 'package:trekverse/pages/add_package.dart';
import 'package:trekverse/pages/add_news.dart';
import 'package:trekverse/pages/admin_show_news.dart';
import 'package:trekverse/pages/admin_show_package.dart';
import 'package:trekverse/pages/update%20news.dart';
import 'update package.dart';
import 'package:trekverse/pages/user_list.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String? username = 'Admin';

  Future<List<Map<String, dynamic>>> fetchUserData() async {
    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('user').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [Color(0xFF4CAF50), Color(0xFF121212), Color(0xFF121212)]
                  : [Color(0xFFA5D6A7), Color(0xFFF4F5F7), Color(0xFFF4F5F7)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Image.asset(
                        "Image/OB.png",
                        height: 250,
                        width: 250,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Hi Admin,",
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                color: isDarkMode ? Colors.white : Color(0xFF344C64),
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, left: 20.0),
                        child: Text(
                          "Let's do some work together,",
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                color: isDarkMode ? Colors.white : Color(0xFF344C64),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [

                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserListPage()));
                      },
                      child: ListTile(
                        title: Text(
                          'User Data',
                          style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64), fontSize: 18),
                        ),
                        leading: Icon(Icons.person, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettingsPage()));
                      },
                      child: ListTile(
                        title: Text(
                          'Theme',
                          style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64), fontSize: 18),
                        ),
                        leading: Icon(Icons.palette, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShowNews()));
                      },
                      child: ListTile(
                        title: Text(
                          'News',
                          style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64), fontSize: 18),
                        ),
                        leading: Icon(Icons.article, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShowPackage()));
                      },
                      child: ListTile(
                        title: Text(
                          'Posts',
                          style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Color(0xFF344C64), fontSize: 18),
                        ),
                        leading: Icon(Icons.compost_rounded, color: isDarkMode ? Colors.white : Color(0xFF344C64)),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        title: Text(
                          'Logout',
                          style: GoogleFonts.nunito(color: Colors.red, fontSize: 18),
                        ),
                        leading: Icon(Icons.exit_to_app, color: Colors.red),
                        tileColor: Color.fromRGBO(59, 28, 50, 1.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Add FAB
          SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            overlayColor: Colors.black,
            overlayOpacity: 0.5,
            children: [
              SpeedDialChild(
                child: Icon(Icons.post_add),
                label: 'Add Product',
                backgroundColor: Colors.greenAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddBrand()));
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.create_new_folder_outlined),
                label: 'Add News',
                backgroundColor: Colors.greenAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddNews()));
                },
              ),
            ],
          ),
          SizedBox(height: 20), // Spacing between FABs

          // Update FAB
          SpeedDial(
            icon: Icons.update,
            activeIcon: Icons.close,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            overlayColor: Colors.black,
            overlayOpacity: 0.5,
            children: [
              SpeedDialChild(
                child: Icon(Icons.tips_and_updates_rounded),
                label: 'Update Product',
                backgroundColor: Colors.greenAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePackage()));
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.new_releases_outlined),
                label: 'Update News',
                backgroundColor: Colors.greenAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateNews()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
