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

}
