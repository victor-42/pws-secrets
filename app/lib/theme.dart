import 'package:flutter/material.dart';

Color primary_color = const Color(0xfffc3742);


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
      useMaterial3: false,
      primarySwatch: createMaterialColor(primary_color),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffffffff),
        foregroundColor: Color(0xff000000),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xfffc3742),
        surface: Color(0xffffffff),
        secondary: Color(0xff000000),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xffffffff),
        selectedItemColor: Color(0xfffc3742),
        unselectedItemColor: Color(0xff000000),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: false).copyWith(
      primaryColor: const Color(0xfffc3742),
      focusColor: const Color(0xfffc3742),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xfffc3742),
        surface: Color(0xff414141),
        secondary:Color(0xff414141),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          // Setting foreground color (text and icon) to white
          foregroundColor: MaterialStateProperty.all<Color>(Color(0xffffffff)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xfffc3742),
        unselectedItemColor: Color(0xffffffff),
        backgroundColor: Color(0xff414141),
      ),
    );
  }
}