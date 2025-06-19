import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Por defecto, modo oscuro

  ThemeMode get themeMode => _themeMode;

  // El constructor ahora solo inicializa en modo oscuro.
  ThemeProvider();

  // El método toggleTheme ya no es necesario ya que siempre estaremos en modo oscuro.
  // void toggleTheme(bool isDarkMode) {
  //   _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  //   notifyListeners(); // Notifica a los oyentes que el tema ha cambiado
  // }
}
