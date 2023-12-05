import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StateManager with ChangeNotifier {
  late final SharedPreferences _prefs;

  StateManager() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs.setInt('themeMode', themeMode.index);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    final int? themeModeIndex = _prefs.getInt('themeMode');
    if (themeModeIndex == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values[themeModeIndex];
  }
}
