import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_tracker_chofer/screens/login_screen.dart';
import 'package:bus_tracker_chofer/utils/location_service.dart';
import 'package:bus_tracker_chofer/utils/supabase_credentials.dart';
import 'package:bus_tracker_chofer/utils/theme_provider.dart';

// Gruvbox Dark
const Color gruvboxDarkBg = Color(0xFF282828);
const Color gruvboxDarkFg = Color(0xFFebdbb2);
const Color gruvboxDarkRed = Color(0xFFcc241d);
const Color gruvboxDarkGreen = Color(0xFF98971a);
const Color gruvboxDarkYellow = Color(0xFFd79921);
const Color gruvboxDarkBlue = Color(0xFF458588);
const Color gruvboxDarkPurple = Color(0xFFb16286);
const Color gruvboxDarkAqua = Color(0xFF689d6a);
const Color gruvboxDarkOrange = Color(0xFFd65d0e);
const Color gruvboxDarkGray =
    Color(0xFFa89984); // Para texto secundario o bordes

// Gruvbox Light
const Color gruvboxLightBg = Color(0xFFfbf1c7);
const Color gruvboxLightFg = Color(0xFF3c3836);
const Color gruvboxLightRed = Color(0xFFcc241d);
const Color gruvboxLightGreen = Color(0xFF98971a);
const Color gruvboxLightYellow = Color(0xFFd79921);
const Color gruvboxLightBlue = Color(0xFF458588);
const Color gruvboxLightPurple = Color(0xFFb16286);
const Color gruvboxLightAqua = Color(0xFF689d6a);
const Color gruvboxLightOrange = Color(0xFFd65d0e);
const Color gruvboxLightGray =
    Color(0xFF7c6f64); // Para texto secundario o bordes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Tema Gruvbox Light
  ThemeData _gruvboxLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: gruvboxLightBlue,
      scaffoldBackgroundColor: gruvboxLightBg,
      cardColor: gruvboxLightBg,
      canvasColor: gruvboxLightBg,
      // Usamos MaterialColor para primarySwatch para compatibilidad,
      // aunque con el nuevo sistema de temas es menos crítico.
      primarySwatch: const MaterialColor(
        0xFF458588, // Color principal (azul Gruvbox)
        <int, Color>{
          50: Color(0xFFD6E3E4), // Lighter shades
          100: Color(0xFFAABCC0),
          200: Color(0xFF7D959A),
          300: Color(0xFF506D70),
          400: Color(0xFF2E4C4F),
          500: gruvboxLightBlue, // Base color
          600: Color(0xFF3F777B),
          700: Color(0xFF37686B),
          800: Color(0xFF2E595D),
          900: Color(0xFF1D3B3E), // Darker shades
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: gruvboxLightBlue,
        foregroundColor: gruvboxLightFg, // Texto en AppBar
        titleTextStyle: TextStyle(
          color: gruvboxLightFg,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: gruvboxLightFg),
        bodyMedium: TextStyle(color: gruvboxLightFg),
        titleLarge: TextStyle(color: gruvboxLightFg),
        titleMedium: TextStyle(color: gruvboxLightFg),
        titleSmall: TextStyle(color: gruvboxLightFg),
        labelLarge: TextStyle(color: gruvboxLightFg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gruvboxLightBlue,
          foregroundColor: gruvboxLightFg, // Color del texto del botón
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              gruvboxLightBlue, // Color del texto del botón de texto
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // ignore: deprecated_member_use
        fillColor: gruvboxLightGray.withOpacity(0.1), // Un poco transparente
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: gruvboxLightGray.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: gruvboxLightGray.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gruvboxLightBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: gruvboxLightFg),
        // ignore: deprecated_member_use
        hintStyle: TextStyle(color: gruvboxLightFg.withOpacity(0.6)),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: gruvboxLightFg,
        iconColor: gruvboxLightFg,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return gruvboxLightBlue;
          }
          return null; // Usa el color predeterminado
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            // ignore: deprecated_member_use
            return gruvboxLightBlue.withOpacity(0.5);
          }
          return null; // Usa el color predeterminado
        }),
      ),
      iconTheme: const IconThemeData(
        color: gruvboxLightFg,
      ),
      // Añade más personalizaciones según necesites
    );
  }

  // Tema Gruvbox Dark
  ThemeData _gruvboxDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: gruvboxDarkBlue,
      scaffoldBackgroundColor: gruvboxDarkBg,
      cardColor: gruvboxDarkBg,
      canvasColor: gruvboxDarkBg,
      primarySwatch: const MaterialColor(
        0xFF458588, // Color principal (azul Gruvbox)
        <int, Color>{
          50: Color(0xFFD6E3E4),
          100: Color(0xFFAABCC0),
          200: Color(0xFF7D959A),
          300: Color(0xFF506D70),
          400: Color(0xFF2E4C4F),
          500: gruvboxDarkBlue,
          600: Color(0xFF3F777B),
          700: Color(0xFF37686B),
          800: Color(0xFF2E595D),
          900: Color(0xFF1D3B3E),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: gruvboxDarkBlue,
        foregroundColor: gruvboxDarkFg, // Texto en AppBar
        titleTextStyle: TextStyle(
          color: gruvboxDarkFg,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: gruvboxDarkFg),
        bodyMedium: TextStyle(color: gruvboxDarkFg),
        titleLarge: TextStyle(color: gruvboxDarkFg),
        titleMedium: TextStyle(color: gruvboxDarkFg),
        titleSmall: TextStyle(color: gruvboxDarkFg),
        labelLarge: TextStyle(color: gruvboxDarkFg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gruvboxDarkBlue,
          foregroundColor: gruvboxDarkFg, // Color del texto del botón
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              gruvboxDarkBlue, // Color del texto del botón de texto
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // ignore: deprecated_member_use
        fillColor: gruvboxDarkGray.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: gruvboxDarkGray.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: gruvboxDarkGray.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gruvboxDarkBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: gruvboxDarkFg),
        // ignore: deprecated_member_use
        hintStyle: TextStyle(color: gruvboxDarkFg.withOpacity(0.6)),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: gruvboxDarkFg,
        iconColor: gruvboxDarkFg,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return gruvboxDarkBlue;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            // ignore: deprecated_member_use
            return gruvboxDarkBlue.withOpacity(0.5);
          }
          return null;
        }),
      ),
      iconTheme: const IconThemeData(
        color: gruvboxDarkFg,
      ),
      // Añade más personalizaciones según necesites
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationService(),
      child: ChangeNotifierProvider<ThemeProvider>(
        create: (context) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          // Consume ThemeProvider para reconstruir al cambiar el tema
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'Bus Tracker Chofer',
              theme: _gruvboxLightTheme(), // Tema para Light
              darkTheme: _gruvboxDarkTheme(), // Tema para Dark
              themeMode: themeProvider.themeMode, // Controla el tema actual
              home: const LoginScreen(),
            );
          },
        ),
      ),
    );
  }
}
