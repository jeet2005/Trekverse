import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class ThemeSettingsPage extends StatefulWidget {
  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool _isHovered = false;
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Theme",
                style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Color(0xFFFFFFFF) : Color(0xFF344C64)),
              ),
              SizedBox(height: 16),
              RadioListTile<ThemeMode>(
                activeColor: Color(0xFF81C784),
                title: Text("Light Mode", style: GoogleFonts.nunito(color: isDarkMode ? Color(0xFFFFFFFF) : Color(0xFF344C64))),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? mode) {
                  themeProvider.setThemeMode(mode!);
                },
              ),
              RadioListTile<ThemeMode>(
                activeColor: Color(0xFF81C784),
                title: Text("Dark Mode", style: GoogleFonts.nunito(color: isDarkMode ? Color(0xFFFFFFFF) : Color(0xFF344C64))),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? mode) {
                  themeProvider.setThemeMode(mode!);
                },
              ),
              RadioListTile<ThemeMode>(
                activeColor: Color(0xFF81C784),
                title: Text("System Mode", style: GoogleFonts.nunito(color: isDarkMode ? Color(0xFFFFFFFF) : Color(0xFF344C64))),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? mode) {
                  themeProvider.setThemeMode(mode!);
                },
              ),
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Theme setting saved!", style: GoogleFonts.nunito())),
                        );
                        setState(() {
                          _isClicked = true;
                          _isHovered = false;
                        });
                        Future.delayed(const Duration(milliseconds: 250), () {
                          setState(() {
                            _isClicked = false;
                          });
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF4CAF50),
                        backgroundColor: _isClicked
                            ? (isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5F7))
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
                      child: Text(
                        "Save Theme",
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                color: _isClicked
                                    ? Color(0xFF4CAF50)
                                    : (isDarkMode ? Colors.black : Colors.white),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)),
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
}
