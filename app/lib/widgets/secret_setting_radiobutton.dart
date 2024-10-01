import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingRadioButton extends StatefulWidget {
  final String title;
  final bool active;
  final Function onClicked;

  SettingRadioButton({
    required this.title,
    required this.active,
    required this.onClicked,
  });

  @override
  State<SettingRadioButton> createState() => _SettingRadioButtonState();
}

class _SettingRadioButtonState extends State<SettingRadioButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.active ?
          Theme.of(context).colorScheme.primary : Color(0xff303030),
        ),
        child: Text(widget.title),
        onPressed: () => widget.onClicked(),
      ),
    );
  }
}