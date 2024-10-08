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
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineLarge: ThemeData.light().textTheme.headlineLarge!.copyWith(
          fontSize: 40,
        ),
        headlineMedium: ThemeData.light().textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w100,
          fontSize: 40,
        ),
        headlineSmall: ThemeData.light().textTheme.headlineSmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          fontFamily: 'SpaceGrotesk',
        ),
        bodyMedium: ThemeData.light().textTheme.bodyMedium!.copyWith(
          color: Color(0xffababab),
          fontFamily: 'ChivoDivo',
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ).apply(
        fontFamily: 'ChivoDivo',
      ),
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
      textTheme: ThemeData.dark().textTheme.copyWith(
        headlineLarge: ThemeData.dark().textTheme.headlineLarge!.copyWith(
          fontSize: 40,
        ),
        headlineMedium: ThemeData.dark().textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w100,
          fontSize: 40,
        ),
        headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          fontFamily: 'SpaceGrotesk',
          color: Color(0xffffffff),
        ),
        bodyMedium: ThemeData.dark().textTheme.bodyMedium!.copyWith(
          color: Color(0xffababab),
          fontFamily: 'ChivoDivo',
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ).apply(
        fontFamily: 'ChivoDivo',
      ),
      primaryColor: const Color(0xfffc3742),
      focusColor: const Color(0xfffc3742),
      scaffoldBackgroundColor: Color(0xff171717),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xfffc3742),
        surface: Color(0xff26262B),
        secondary:Color(0xff26262B),
        background: Color(0xff303030),
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
        backgroundColor: Color(0xff26262B),
      ),
      cardColor: Color(0xff26262B),
    );
  }
}

int breakpointSmall = 600;
int breakpointMedium = 900;
int breakpointLarge = 1200;