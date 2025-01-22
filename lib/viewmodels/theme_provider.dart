import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ThemeProvider extends ChangeNotifier {
  late ThemeData _selectedTheme;

  ThemeProvider({bool isDark = false}) {
    _selectedTheme = isDark ? _darkTheme : _lightTheme;
  }

  ThemeData get getTheme => _selectedTheme;

  Future<void> changeTheme() async {
    final FlutterSecureStorage _storage = FlutterSecureStorage();

    if (_selectedTheme == _darkTheme) {
      _selectedTheme = _lightTheme;
      await _storage.write(key: 'isDark', value: 'false');
    } else {
      _selectedTheme = _darkTheme;
      await _storage.write(key: 'isDark', value: 'true');
    }

    // Notify all listeners about the theme change
    notifyListeners();
  }

  // Corrected Light Theme
  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue.shade700,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Montserrat'),
      bodyMedium: TextStyle(fontFamily: 'Montserrat'),
      displayLarge: TextStyle(fontFamily: 'Montserrat'),
      displayMedium: TextStyle(fontFamily: 'Montserrat'),
    ),
  );
// Corrected Dark Theme
  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue.shade700,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Montserrat'),
      bodyMedium: TextStyle(fontFamily: 'Montserrat'),
      displayLarge: TextStyle(fontFamily: 'Montserrat'),
      displayMedium: TextStyle(fontFamily: 'Montserrat'),
    ),
  );
}
