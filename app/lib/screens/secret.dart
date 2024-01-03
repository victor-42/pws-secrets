import 'package:flutter/material.dart';

import '../secret-forms/image.dart';
import '../secret-forms/login.dart';
import '../secret-forms/note.dart';
import '../widgets/radio_card_button.dart';

class SecretScreen extends StatefulWidget {
  const SecretScreen({Key? key}) : super(key: key);

  @override
  State<SecretScreen> createState() => SecretScreenState();
}


class SecretScreenState extends State<SecretScreen> {
  int _mode = 0;
  final List<Widget> _forms = [
    const NoteForm(),
    const LoginForm(),
    const ImageForm(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            // Radio Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RadioCardButton(
                  title: 'Note',
                  iconWidget: const Icon(Icons.lock),
                  active: _mode == 0,
                  onClicked: () {
                    setState(() {
                      _mode = 0;
                    });
                  },
                ),
                RadioCardButton(
                  title: 'Login',
                  iconWidget: const Icon(Icons.note),
                  active: _mode == 1,
                  onClicked: () {
                    setState(() {
                      _mode = 1;
                    });
                  },
                ),
                RadioCardButton(
                  title: 'Image',
                  iconWidget: const Icon(Icons.image),
                  active: _mode == 2,
                  onClicked: () {
                    setState(() {
                      _mode = 2;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 24),
            // Form
            _forms[_mode],
          ],
        );
  }
}