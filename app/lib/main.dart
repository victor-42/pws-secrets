import 'package:app/screens/about.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/secret.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pws_secrets',
      themeMode: _themeMode,
      theme: SecretsTheme.lightTheme,
      darkTheme: SecretsTheme.darkTheme,
      home: MyHomePage(
        title: 'PWS Secrets',
        onThemeToggle: toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.title, required this.onThemeToggle});

  final String title;
  final Function(bool) onThemeToggle;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ThemeMode _themeMode = ThemeMode.system;
  int _selectedIndex = 1;
  final screens = [const LastSecretsScreen(), const SecretScreen(), const AboutScreen()];

  @override
  void initState() {
    super.initState();
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    _themeMode =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 24),
              Image.asset(
                _themeMode == ThemeMode.light
                    ? 'logo/pws_black.png'
                    : 'logo/pws_white.png',
                fit: BoxFit.contain,
                height: 32,
              ),
              IconButton(
                icon: _themeMode == ThemeMode.light
                    ? const Icon(Icons.dark_mode)
                    : const Icon(Icons.light_mode),
                onPressed: () {
                  widget.onThemeToggle(_themeMode == ThemeMode.light);
                  setState(() {
                    _themeMode = _themeMode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  });
                },
              ),
            ],
          ),
        ),
        body: screens[_selectedIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.key),
                  label: 'Secret',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info),
                  label: 'About',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (int index) => {
                    setState(
                      () {
                        _selectedIndex = index;
                      },
                    )
                  }),
        ));
  }
}
