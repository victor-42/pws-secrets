import 'dart:async';
import 'dart:html';

import 'package:app/theme.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import '../state-manager.dart';

class RevealScreen extends StatefulWidget {
  const RevealScreen({Key? key}) : super(key: key);

  @override
  State<RevealScreen> createState() => RevealScreenState();
}

class RevealScreenState extends State<RevealScreen> {
  final StateManager _stateManager = locator<StateManager>();
  dynamic _secret;
  int _currentTimerTime = -10;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    window.history.pushState(null, '/secret/', '#');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTimerTime >= 0) {
        _timer?.cancel();
        Navigator.of(context).pop();
      }
      setState(() {
        _currentTimerTime = _currentTimerTime + 1;
      });
    });
  }

  Future<void> _initState() async {
    await _stateManager.initPrefs();
    setState(() {
      _secret = _stateManager.getSecret();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${_currentTimerTime <= 0 ? '-' : '+'} '
                '${(_currentTimerTime.abs() ~/ 86400).toString().padLeft(2, '0')}:'
                '${(_currentTimerTime.abs() ~/ 3600 % 24).toString().padLeft(2, '0')}:'
                '${(_currentTimerTime.abs() ~/ 60 % 60).toString().padLeft(2, '0')}:'
                '${(_currentTimerTime.abs() % 60).toString().padLeft(2, '0')}'),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(child: LoginRevealScreen()),
    );
  }
}

class LoginRevealScreen extends StatefulWidget {
  const LoginRevealScreen({Key? key}) : super(key: key);

  @override
  State<LoginRevealScreen> createState() => LoginRevealScreenState();
}

class LoginRevealScreenState extends State<LoginRevealScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Username',
                  style: Theme.of(context).textTheme.headlineSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
                  Text('vector4wedwewefseffsdf2',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: primary_color)),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Password', style: Theme.of(context).textTheme.headlineSmall),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
            Text('fadfasfdsafs',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: primary_color))
          ]),
        ]);
  }
}

class InvalidScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      children: [
        Icon(Icons.error_outline),
        SizedBox(width: 10),
        Text('Invalid Secret!'),
      ],
    ));
  }
}
