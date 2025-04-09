import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Color(0xFF4CAF50),

        title: Text(
          'About Us',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Color(0xFF2E7D32) : Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: isDarkMode ? Color(0xFF81C784) : Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDarkMode ? Color(0xFF121212) : Color(0xFFA5D6A7),
                isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5F7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'Image/OB.png',
                    width: 400,
                    height: 400,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Trekverse!',
                  style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Trekverse is a leading platform dedicated to helping adventure enthusiasts discover and plan their next trekking journey. With expert guides and carefully curated trekking packages, we make sure that every adventure is unforgettable.',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Our Mission:',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We aim to connect trekkers with nature and provide them with exceptional experiences, ensuring they have the guidance and support they need on their journey.',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Our Services:',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '- Curated trekking packages\n- Expert trekking guides\n- Customizable itineraries\n- Equipment and permits assistance\n- 24/7 customer support',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode ? Colors.white : Color(0xFF344C64),
                  ),
                ),
                const SizedBox(height: 30),
]
            ),
          ),
        ),
      ),
    );
  }
}
