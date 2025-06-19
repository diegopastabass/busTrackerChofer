import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Gruvbox Dark Palette
  static const Color gruvboxDarkBg =
      Color(0xFF282828); // Dark black for backgrounds
  static const Color gruvboxDarkFg = Color(0xFFebdbb2); // Light grey for text
  static const Color gruvboxDarkRed = Color(0xFFcc241d); // Red for accents
  static const Color gruvboxDarkBlue =
      Color(0xFF83a598); // Light blue for routes
  static const Color gruvboxDarkDarkBlue =
      Color(0xFF458588); // Dark blue for bus stops
  static const Color gruvboxDarkGrey = Color(0xFF928374); // Dark grey for cards
  static const Color gruvboxDarkLightGrey =
      Color(0xFFa89984); // Light grey for buttons
  static const Color gruvboxDarkAppBar =
      Color(0xFF3c3836); // Light black for app bars

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(color: gruvboxDarkFg), // Text color
        ),
        backgroundColor: gruvboxDarkAppBar, // Light black for app bar
        iconTheme:
            const IconThemeData(color: gruvboxDarkFg), // Back button color
      ),
      backgroundColor: gruvboxDarkBg, // Dark black for background
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'La aplicación está en modo oscuro por defecto.',
                style: TextStyle(color: gruvboxDarkFg),
              ),
              // Puedes añadir más elementos o dejarlo como informativo
            ),
          ],
        ),
      ),
    );
  }
}
