import 'package:flutter/material.dart';

class SecretScreen extends StatefulWidget {
  const SecretScreen({Key? key}) : super(key: key);

  @override
  State<SecretScreen> createState() => SecretScreenState();
}


class SecretScreenState extends State<SecretScreen> {
  @override
  Widget build(BuildContext context) {
    return Text('Secret Screen');
  }
}