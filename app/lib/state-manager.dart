import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:html';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StateManager {
  SharedPreferences? _prefs;

  //String apiUrl = '${Uri.base.origin}/api/';
  String apiUrl = 'http://localhost:8000/api/';
  List<String> _archivedUuidList = [];
  DateTime? oldExpiration;
  List<SecretArchive>? oldArchives;

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadOldUuidList();
  }

  Future<void> reloadHomeInformation() async {
    oldArchives = await getSecretArchives();
    oldExpiration = await getOldExpiration();
  }

  Future<bool> rotateKey() async {
    return http.post(
      Uri.parse('${apiUrl}key-rotation/'),
      headers: {
        'Content-Type': 'application/json',
      },
    ).then((response) {
      if (response.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    });
  }

  Future<Map<String, dynamic>?> retrieveSecret(String encrypted) async {
    return http.get(
      Uri.parse('${apiUrl}sc/$encrypted/'),
      headers: {
        'Content-Type': 'application/json',
      },
    ).then((response) {
      if (response.statusCode != 200) {
        return null;
      } else {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    });
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
    saveMeta ??= false;
    SecretPreferences obj = SecretPreferences(
      showFor: showFor,
      expireIn: expireIn,
      saveMeta: saveMeta,
    );
    return obj;
  }

  Future<DateTime?> getOldExpiration() async {
    return http.get(
      Uri.parse('${apiUrl}key-rotation/'),
      headers: {
        'Content-Type': 'application/json',
      },
    ).then((response) {
      if (response.statusCode != 200) {
        throw Exception('Failed to load old expiration');
      } else {
        var rotated_at = jsonDecode(response.body)['rotated_at'];
        if (rotated_at == null) return null;
        return DateTime.parse(rotated_at);
      }
    });
  }

  Future<List<SecretArchive>> getSecretArchives() async {
    if (_archivedUuidList.isEmpty) return [];
    return http.put(
      Uri.parse('${apiUrl}secrets/'),
      body: json.encode({
        'ids': _archivedUuidList,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    ).then((response) {
      if (response.statusCode != 200) {
        throw Exception('Failed to load secret archives');
      } else {
        var archives = jsonDecode(response.body); // List of secret archives
        List<SecretArchive> objs = [];
        for (var data in archives) {
          objs.add(SecretArchive(
            uuid: data['uuid'],
            type: data['type'],
            expiration: DateTime.parse(data['expiration']),
            createdAt: DateTime.parse(data['created_at']),
            openedAt: data['opened_at'] != null
                ? DateTime.parse(data['opened_at'])
                : null,
          ));
        }
        return objs;
      }
    });
  }

  Future<void> saveOldUuidList() async {
    await _prefs?.setStringList('ArchivedUuidList', _archivedUuidList);
  }

  void loadOldUuidList() async {
    _archivedUuidList = _prefs?.getStringList('ArchivedUuidList') ?? [];
  }

  Future<void> setStringPreference(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<String?> getSecret() async {
    return await _prefs?.getString('Secret');
  }

  Future<String?> createSecret(
      String type, dynamic secret, SecretPreferences preferences) async {
    // Generate uuid
    var uuid = const Uuid().v4();

    callb(response) {
      if (response.statusCode != 201) {
        return null;
      } else {
        if (preferences.saveMeta) {
          _archivedUuidList.add(uuid);
          saveOldUuidList();
        }

        String pathname = window.location.pathname.toString();
        return '${window.location.href.replaceAll(pathname == '/' ? 'LOLULOVER' : pathname, '')}${pathname == '/' ? '' : '/'}secret/'.replaceAll('/#', '/') +
            jsonDecode(response.body)['enc'];
      }
    }

    Map<String, String> repr = {
      'uuid': uuid,
      'type': type,
      'expiration_date': DateTime.now()
          .add(Duration(hours: preferences.expireIn))
          .toIso8601String(),
      'view_time': preferences.showFor.toString()
    };

    if (type == 'i') {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse('${apiUrl}not-secret/'),
      );
      req.fields.addAll(repr);
      req.fields.addAll((secret as ImageSecret).getRepresentation());
      req.files.add(
        http.MultipartFile.fromBytes(
          'image',
          (secret as ImageSecret).imageBytes,
          filename: (secret as ImageSecret).imageFileName,
          contentType: MediaType('image', secret.imageFileName.split('.').last),
        )
      );
      return http.Response.fromStream(await req.send()).then(callb);
    }
    repr.addAll(secret.getRepresentation());
    return http.post(
      Uri.parse('${apiUrl}not-secret/'),
      body: jsonEncode(repr),
      headers: {
        'Content-Type': 'application/json',
      },
    ).then(callb);
  }

  void clearOldArchives() {
    // Filter the Archives for those that are already opened
    List<String> uuidsToBeRemoved = _archivedUuidList
        .where((element) =>
            oldArchives?.firstWhere((e) => e.uuid == element).openedAt != null)
        .toList();

    blockArchives(uuidsToBeRemoved);
    _archivedUuidList = _archivedUuidList
        .where((element) =>
            oldArchives?.firstWhere((e) => e.uuid == element).openedAt == null)
        .toList();
    oldArchives =
        oldArchives?.where((element) => element.openedAt == null).toList();

    saveOldUuidList();
  }

  blockArchive(String uuid) async {
    return blockArchives([uuid]).then((value) {
      if (value) {
        _archivedUuidList.remove(uuid);
        saveOldUuidList();
        oldArchives =
            oldArchives?.where((element) => element.uuid != uuid).toList();
      }
    });
  }

  Future<bool> blockArchives(List<String> uuids) async {
    return http.patch(
      Uri.parse('${apiUrl}secrets/'),
      body: jsonEncode({
        'ids': uuids,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    ).then((response) {
      if (response.statusCode != 204) {
        return false;
      } else {
        return true;
      }
    });
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

class NoteSecret {
  final String type = 'n';
  final String note;

  NoteSecret({
    required this.note,
  });

  getRepresentation() {
    return {
      'note': note,
    };
  }
}

class PasswordSecret {
  final String type = 'p';
  final String username;
  final String password;

  PasswordSecret({
    required this.username,
    required this.password,
  });

  getRepresentation() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class ImageSecret {
  final String type = 'i';
  final String imageFileName;
  final Uint8List imageBytes;
  final String note;

  ImageSecret({
    required this.imageFileName,
    required this.imageBytes,
    required this.note,
  });

  getRepresentation() {
    return {
      'note': note,
    };
  }
}
