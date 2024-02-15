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


class SecretArchive {
  final String uuid;
  final String type;
  final DateTime expiration;
  final DateTime createdAt;
  final DateTime? openedAt;

  SecretArchive({
    required this.uuid,
    required this.type,
    required this.expiration,
    required this.createdAt,
    required this.openedAt,
  });
}
