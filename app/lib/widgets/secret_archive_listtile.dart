import 'package:app/state-manager.dart';
import 'package:flutter/material.dart';

class SArchiveTile extends StatelessWidget {
  final SecretArchive secretArchive;

  SArchiveTile({required this.secretArchive});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('alfksjdakljaklsdd'),
      subtitle: Text('Last modified: blablalblabla'),
    );
  }
}