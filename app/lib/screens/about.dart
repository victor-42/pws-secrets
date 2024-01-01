import 'package:flutter/cupertino.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Text('About Screen');
  }
}