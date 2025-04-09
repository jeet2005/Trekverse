import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:trekverse/pages/home.dart';
import 'package:trekverse/pages/profile.dart';
import 'package:trekverse/pages/search.dart';
import 'package:trekverse/pages/wishlist.dart';
import 'package:trekverse/pages/news.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;
  late Home home;
  late Search search;
  late Wishlist wishlist;
  late News news;
  late Profile profile;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    home = Home();
    search = Search();
    wishlist = Wishlist();
    news = News();
    profile = Profile();
    pages = [home, wishlist, search, news, profile];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Color(0xFF4CAF50) : Color(0xFFA5D6A7),
              offset: Offset(0, -15),
              blurRadius: 50,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SalomonBottomBar(
          currentIndex: currentTabIndex,
          onTap: (index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
              selectedColor: isDarkMode ? Color(0xFF81C784) : Color(0xFF4CAF50),
              unselectedColor: isDarkMode ? Color(0xFFB0B0B0) : Color(0xFFB0B0B0),
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite),
              title: Text('Wishlist'),
              selectedColor: isDarkMode ? Color(0xFF81C784) : Color(0xFF4CAF50),
              unselectedColor: isDarkMode ? Color(0xFFB0B0B0) : Color(0xFFB0B0B0),
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.search),
              title: Text('Search'),
              selectedColor: isDarkMode ? Color(0xFF81C784) : Color(0xFF4CAF50),
              unselectedColor: isDarkMode ? Color(0xFFB0B0B0) : Color(0xFFB0B0B0),
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.trending_up),
              title: Text('News'),
              selectedColor: isDarkMode ? Color(0xFF81C784) : Color(0xFF4CAF50),
              unselectedColor: isDarkMode ? Color(0xFFB0B0B0) : Color(0xFFB0B0B0),
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('Profile'),
              selectedColor: isDarkMode ? Color(0xFF81C784) : Color(0xFF4CAF50),
              unselectedColor: isDarkMode ? Color(0xFFB0B0B0) : Color(0xFFB0B0B0),
            ),
          ],
        ),
      ),
    );
  }
}
