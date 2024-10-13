import 'dart:html';

import 'package:app/locator.dart';
import 'package:app/screens/about.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/reveal.dart';
import 'package:app/screens/secret.dart';
import 'package:app/state-manager.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleThemeMode() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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
        toggleThemeMode: toggleThemeMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Function() toggleThemeMode;

  const MyHomePage(
      {super.key, required this.title, required this.toggleThemeMode});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<SecretScreenState> _secretScreenKey =
      GlobalKey<SecretScreenState>();
  final GlobalKey<AboutScreenState> _aboutScreenKey =
      GlobalKey<AboutScreenState>();
  int _selectedIndex = 0;
  int? _aboutAccordionIndex;

  @override
  void initState() {
    super.initState();
    var url = window.location.href;
    if (url.contains('/secret/')) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showStartupDialog(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
              icon: Theme.of(context).brightness == Brightness.dark
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.dark_mode),
              onPressed: () {
                setState(() {
                  widget.toggleThemeMode();
                });
              },
            ),
          ],
          title: Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/logo/secrets_white_small.png'
                : 'assets/logo/secrets_black_small.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
            height: 32,
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            LastSecretsScreen(
              onToNewSecrets: (int? mode) {
                if (mode != null) {
                  _secretScreenKey.currentState?.changeMode(mode);
                }
                setState(() {
                  _selectedIndex = 1;
                });
              },
              onToAbout: (int accordionIndex) {
                setState(() {
                  _aboutScreenKey.currentState
                      ?.setAccordionIndex(accordionIndex);
                  _selectedIndex = 2;
                });
              },
            ),
            SecretScreen(
              key: _secretScreenKey,
            ),
            AboutScreen(
              key: _aboutScreenKey,
            ),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/secret-icons/pirate_white.png'
                        : 'assets/secret-icons/pirate.png',
                    color: _selectedIndex == 1
                        ? Theme.of(context).primaryColor
                        : null,
                    height: 24,
                  ),
                  label: 'Secret',
                ),
                const BottomNavigationBarItem(
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

  void _showStartupDialog(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => RevealScreen(),
      fullscreenDialog:
          true, // This makes the page slide up from the bottom and include a close button on iOS.
    ));
  }
}
