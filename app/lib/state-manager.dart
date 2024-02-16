import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateManager {
  SharedPreferences? _prefs;

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveSecretPreferences(SecretPreferences val) async {
    if (val.showFor != null) await _prefs?.setInt('ShowFor', val.showFor!);
    await _prefs?.setInt('ExpireIn', val.expireIn);
    await _prefs?.setBool('SaveMeta', val.saveMeta);
  }

  SecretPreferences getSecretPreferences() {
    var showFor = _prefs?.getInt('ShowFor');
    var expireIn = _prefs?.getInt('ExpireIn');
    var saveMeta = _prefs?.getBool('SaveMeta');
    expireIn ??= 24;
    saveMeta ??= true;
    SecretPreferences obj = SecretPreferences(
      showFor: showFor,
      expireIn: expireIn,
      saveMeta: saveMeta,
    );
    return obj;
  }

  Future<void> setStringPreference(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<String?> getSecret() async {
    return await _prefs?.getString('Secret');
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

class SecretPreferences {
  int? showFor;
  int expireIn = 24;
  bool saveMeta = true;

  SecretPreferences({
    required this.showFor,
    required this.expireIn,
    required this.saveMeta,
  }) {}
}
