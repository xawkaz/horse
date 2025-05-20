import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Charger le thème depuis les préférences
  _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Basculer entre le mode clair et le mode sombre
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Thème clair - Design moderne et vif
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF3A5BA0), // Bleu plus foncé pour contraste
      fontFamily: 'Roboto', // Police par défaut
      colorScheme: ColorScheme.light(
        // Couleurs principales pour le mode clair - palette vive et moderne
        primary: const Color(0xFF3A5BA0), // Bleu plus foncé pour contraste
        secondary: const Color(0xFFE65100), // Orange vif pour accent
        background: const Color(0xFFF8F9FB), // Presque blanc
        surface: Colors.white, // Blanc pur
        // Couleurs de texte
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: const Color(0xFF1A1A1A), // Presque noir
        onSurface: const Color(0xFF1A1A1A), // Presque noir
        // Couleurs d'accentuation
        error: const Color(0xFFD32F2F), // Rouge vif
        tertiary: const Color(0xFF00BFA5), // Turquoise vif
        outline: const Color(0xFFB0BEC5), // Gris bleuté clair
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FB), // Presque blanc
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)), // Presque noir
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1A1A), // Presque noir
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          color: Color(0xFF1A1A1A), // Presque noir
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontFamily: 'Poppins',
        ),
        displayMedium: const TextStyle(
          color: Color(0xFF1A1A1A), // Presque noir
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontFamily: 'Poppins',
        ),
        bodyLarge: const TextStyle(
          color: Color(0xFF1A1A1A), // Presque noir
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: const TextStyle(
          color: Color(0xFF455A64), // Gris bleuté foncé
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          color: Color(0xFF1A1A1A), // Presque noir
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A5BA0), // Bleu plus foncé
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF3A5BA0).withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide.none, // Pas de bordure
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white, // Blanc pur
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5), width: 1), // Gris bleuté clair
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A5BA0), width: 2), // Bleu plus foncé
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5), width: 1), // Gris bleuté clair
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF616161), // Gris moyen
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        hintStyle: TextStyle(
          color: const Color(0xFF9E9E9E).withOpacity(0.8), // Gris clair
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF3A5BA0), // Bleu plus foncé
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        prefixIconColor: const Color(0xFF455A64), // Gris bleuté foncé
        suffixIconColor: const Color(0xFF455A64), // Gris bleuté foncé
      ),
    );
  }

  // Thème sombre - Design professionnel
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF64B5F6), // Bleu clair
      fontFamily: 'Roboto', // Police par défaut
      colorScheme: ColorScheme.dark(
        // Couleurs principales pour le mode sombre - palette professionnelle
        primary: const Color(0xFF64B5F6), // Bleu clair
        secondary: const Color(0xFF7986CB), // Bleu-violet clair
        background: const Color(0xFF121212), // Gris foncé
        surface: const Color(0xFF1E1E1E), // Gris un peu plus clair
        // Couleurs de texte
        onPrimary: Colors.black, // Texte noir sur fond clair
        onSecondary: Colors.black, // Texte noir sur fond clair
        onBackground: Colors.white, // Texte blanc sur fond foncé
        onSurface: Colors.white, // Texte blanc sur fond foncé
        // Couleurs d'accentuation
        error: const Color(0xFFEF5350), // Rouge clair
        tertiary: const Color(0xFF4DB6AC), // Vert-bleu clair (teal)
        outline: const Color(0xFF424242), // Gris pour bordures
      ),
      scaffoldBackgroundColor: const Color(0xFF121212), // Gris foncé pour le mode sombre
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Blanc (mode sombre)
        titleTextStyle: TextStyle(
          color: Colors.white, // Blanc (mode sombre)
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          color: Colors.white, // Blanc (mode sombre)
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontFamily: 'Poppins',
        ),
        displayMedium: const TextStyle(
          color: Colors.white, // Blanc (mode sombre)
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontFamily: 'Poppins',
        ),
        bodyLarge: const TextStyle(
          color: Colors.white, // Blanc (mode sombre)
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: const TextStyle(
          color: Color(0xFFBDBDBD), // Gris clair (mode sombre)
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          color: Colors.white, // Blanc (mode sombre)
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF64B5F6), // Bleu clair
          foregroundColor: Colors.black, // Texte noir pour contraste
          elevation: 4,
          shadowColor: const Color(0xFF64B5F6).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF424242), width: 1), // Bordure gris foncé
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Gris foncé pour les champs
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF424242), width: 1), // Bordure gris foncé
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2), // Bleu clair
        ),
        labelStyle: const TextStyle(
          color: Colors.white, // Blanc
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        hintStyle: TextStyle(
          color: const Color(0xFFBDBDBD).withOpacity(0.8), // Gris clair
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF64B5F6), // Bleu clair
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        prefixIconColor: const Color(0xFFBDBDBD), // Gris clair
        suffixIconColor: const Color(0xFFBDBDBD), // Gris clair
      ),
    );
  }
}
