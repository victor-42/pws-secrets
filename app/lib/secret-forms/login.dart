import 'dart:math';

import 'package:app/state-manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 12 color steps from green to red
const List<Color> _securityColors = [
  Color(0xff00ff00),
  Color(0xff33ff00),
  Color(0xff66ff00),
  Color(0xff99ff00),
  Color(0xffccff00),
  Color(0xffffff00),
  Color(0xffffcc00),
  Color(0xffff9900),
  Color(0xffff6600),
  Color(0xffff3300),
  Color(0xffff0000),
  Color(0xffcc0000)
];

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key, required this.onChanged, required this.onSaved})
      : super(key: key);

  final Function(PasswordSecret) onChanged;
  final Function() onSaved;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _generatorVisible = false;
  int _generatorLength = 16;
  int _securityLevel = 7; // 0 - 12
  bool _digits = true;
  bool _specialCharacters = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Call the function with username and password
    }
  }

  void _onTextChanged() {
    widget.onChanged(PasswordSecret(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }

  @override
  void initState() {
    super.initState();
    if (_generatorVisible) _generatePassword();
    _usernameController.addListener(_onTextChanged);
    _passwordController.addListener(_onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Username', border: OutlineInputBorder()),
              validator: (value) {
                return null;
              },
              controller: _usernameController,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.restart_alt),
                  onPressed: () {
                    setState(() {
                      _generatorVisible = !_generatorVisible;
                      if (_generatorVisible) _generatePassword();
                    });
                  },
                ),
              ),
              obscureText: false,
              validator: (value) {
                return null;
              },
              controller: _passwordController,
            ),
            // Password Generating Form with preview, length slider, digits and spechial character toggles. Should be box under input

            AnimatedContainer(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0)),
                color: Theme.of(context).colorScheme.surface,
              ),
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              clipBehavior: Clip.hardEdge,
              height: _generatorVisible ? 213 : 0,
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 12; i++)
                        Expanded(
                          child: Container(
                              height: 5,
                              width: double.infinity,
                              // Get i-d color from green to red with 12 steps
                              color: _securityLevel <= i
                                  ? Colors.grey
                                  : _securityColors[11 - i]),
                        ),
                    ],
                  ),
                  Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Length: $_generatorLength'),
                          Slider(
                            value: _generatorLength.toDouble(),
                            min: 8,
                            max: 64,
                            divisions: 14,
                            label: '$_generatorLength characters',
                            onChanged: (double value) {
                              setState(() {
                                _generatorLength = value.toInt();
                                _generatePassword();
                              });
                            },
                          ),
                          // Digits and Special Characters Toggles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Digits'),
                              CupertinoSwitch(
                                value: _digits,
                                activeColor:
                                Theme.of(context).colorScheme.primary,
                                onChanged: (bool value) {
                                  setState(() {
                                    _digits = value;
                                    _generatePassword();
                                  });
                                },
                              ),
                              Text('Special Characters'),
                              CupertinoSwitch(
                                value: _specialCharacters,
                                activeColor:
                                Theme.of(context).colorScheme.primary,
                                onChanged: (bool value) {
                                  setState(() {
                                    _specialCharacters = value;
                                    _generatePassword();
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: double.infinity,
                            // Copy to clipboard button
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.surface),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary)))),
                              onPressed: () {
                                Clipboard.setData(new ClipboardData(
                                    text: _passwordController.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard'),
                                  ),
                                );
                              },
                              child: Text('Copy to clipboard'),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ));
  }

  void _generatePassword() {
    // Generate a password with the given length and options
    var password = '';
    var characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_digits) {
      characters += '0123456789';
    }
    if (_specialCharacters) {
      characters += '!@#%^&*()';
    }
    var rng = Random();
    for (var i = 0; i < _generatorLength; i++) {
      password += characters[rng.nextInt(characters.length)];
    }
    _passwordController.text = password;
    _securityLevel = (_passwordController.text.length ~/ 3) +
        (_digits ? 2 : 0) +
        (_specialCharacters ? 3 : 0);
  }
}
