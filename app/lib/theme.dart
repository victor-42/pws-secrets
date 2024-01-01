import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class SecretsTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(const Color(0xfffc3742)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffffffff),
        foregroundColor: Color(0xff000000),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xffffffff),
        selectedItemColor: Color(0xfffc3742),
        unselectedItemColor: Color(0xff000000),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xfffc3742),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xfffc3742),
        unselectedItemColor: Color(0xffffffff),
      ),
    );
  }
}