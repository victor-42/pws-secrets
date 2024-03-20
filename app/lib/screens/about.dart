import 'dart:async';

import 'package:app/state-manager.dart';
import 'package:app/widgets/accordion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  int _currentTimerTime = -10;
  Timer? _timer;
  bool _isRotating = false;
  final StateManager _stateManager = locator<StateManager>();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    await _stateManager.initPrefs();
    await _stateManager.reloadHomeInformation();
    // Current Timer time as diff between now and oldExpiration in seconds
    if (_stateManager.oldExpiration == null) {
      _currentTimerTime = 1;
      return;
    }
    _currentTimerTime =
        _stateManager.oldExpiration!.difference(DateTime.now()).inSeconds -
            (72 + 1) * 3600;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTimerTime = _currentTimerTime + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              SecretsAccordion(
                  title: 'Imprint',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                            'This is a simple app to manage your secrets.'),
                      const Text(
                          'It is a demo app for the Flutter & Dart course.'),
                      const Text('It is not intended for production use.'),
                    ],
                  )),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer),
                        SizedBox(width: 10),
                        Text('${_currentTimerTime <= 0 ? '-' : '+'} '
                            '${(_currentTimerTime.abs() ~/ 86400).toString().padLeft(2, '0')}:'
                            '${(_currentTimerTime.abs() ~/ 3600 % 24).toString().padLeft(2, '0')}:'
                            '${(_currentTimerTime.abs() ~/ 60 % 60).toString().padLeft(2, '0')}:'
                            '${(_currentTimerTime.abs() % 60).toString().padLeft(2, '0')}'),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: _currentTimerTime > 0 && !_isRotating
                            ? () {
                                setState(() {
                                  _isRotating = true;
                                });
                                _stateManager.rotateKey().then((value) {
                                  if (value) {
                                    _initState();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Failed to rotate key. Try again later...'),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    _isRotating = false;
                                  });
                                });
                              }
                            : null,
                        child: _isRotating
                            ? SizedBox(
                                height: 15,
                                width: 15,
                                child: const CircularProgressIndicator())
                            : const Text('Request Rotation'),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
