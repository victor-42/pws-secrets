import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  int? _currentTimerTime = null;
  Timer? _timer;
  bool invalid = false;
  Map<String, String>? _secretObj;
  String? _secretType;

  @override
  void dispose() {
    _timer?.cancel();
    window.history.pushState(null, '/secret/', '#');
    _stateManager.reloadHomeInformation();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    var secret = window.location.href.split('/')[4];
    var secretObj = await _stateManager.retrieveSecret(secret);
    if (secretObj == null) {
      print('Invalid secret');

      setState(() {
        invalid = true;
      });
      return;
    }
    int? showFor = secretObj['view_time'];

    setState(() {
      _secretType = secretObj['type'];
      _secretObj = Map.from(secretObj['secret']);
      if (showFor != null) {
        _currentTimerTime = -showFor;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_currentTimerTime! >= 0) {
            _timer?.cancel();
            Navigator.of(context).pop();
          }
          setState(() {
            _currentTimerTime = _currentTimerTime! + 1;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Builder(builder: (context) {
          if (_currentTimerTime == null) {
            if (invalid) {
              return Text('Invalid Secret');
            }
            return Text('Reveal');
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${_currentTimerTime! <= 0 ? '-' : '+'} '
                  '${(_currentTimerTime!.abs() ~/ 86400).toString().padLeft(2, '0')}:'
                  '${(_currentTimerTime!.abs() ~/ 3600 % 24).toString().padLeft(2, '0')}:'
                  '${(_currentTimerTime!.abs() ~/ 60 % 60).toString().padLeft(2, '0')}:'
                  '${(_currentTimerTime!.abs() % 60).toString().padLeft(2, '0')}'),
            ],
          );
        }),
        backgroundColor: Colors.transparent,
      ),
      body: Builder(builder: (context) {
        Widget child = InvalidScreen();
        if (!invalid && _secretType == null) {
          child = CircularProgressIndicator();
        } else if (_secretType == 'n') {
          child = NoteRevealScreen(secretObj: _secretObj ?? {});
        } else if (_secretType == 'p') {
          child = LoginRevealScreen(secretObj: _secretObj ?? {});
        } else if (_secretType == 'i') {
          child = ImageRevealScreen(secretObj: _secretObj ?? {});
        }
        return Center(child: child);
      }),
    );
  }
}

class LoginRevealScreen extends StatefulWidget {
  final Map<String, String> secretObj;

  const LoginRevealScreen({Key? key, required this.secretObj})
      : super(key: key);

  @override
  State<LoginRevealScreen> createState() => LoginRevealScreenState();
}

class ImageRevealScreen extends StatefulWidget {
  final Map<String, String> secretObj;

  const ImageRevealScreen({Key? key, required this.secretObj})
      : super(key: key);

  @override
  State<ImageRevealScreen> createState() => ImageRevealScreenState();
}

class ImageRevealScreenState extends State<ImageRevealScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800, maxHeight: 800),
          child: Image.memory(
            base64Decode(
              widget.secretObj['image'] ?? '',
            ),
            gaplessPlayback: true,
          ),
        ),
        SizedBox(height: 20),
        Text(widget.secretObj['note'] ?? '',
            style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
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
                  IconButton(
                      onPressed: () {
                        Clipboard.setData(new ClipboardData(
                            text: widget.secretObj['username'] ?? ''));
                      },
                      icon: Icon(Icons.copy)),
                  Flexible(
                    child: Text(widget.secretObj['username'] ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: primary_color)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Password', style: Theme.of(context).textTheme.headlineSmall),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.secretObj['password'] ?? ''));
                },
                icon: Icon(Icons.copy)),
            Flexible(
              child: Text(widget.secretObj['password'] ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: primary_color)),
            )
          ]),
        ]);
  }
}

class NoteRevealScreen extends StatefulWidget {
  final Map<String, String> secretObj;

  const NoteRevealScreen({Key? key, required this.secretObj}) : super(key: key);

  @override
  State<NoteRevealScreen> createState() => NoteRevealScreenState();
}

class NoteRevealScreenState extends State<NoteRevealScreen> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Text(widget.secretObj['note'] ?? '',
            style: Theme.of(context).textTheme.headlineSmall));
  }
}

class InvalidScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline),
        SizedBox(height: 10),
        Text('Invalid Secret',
            style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(
          height: 30,
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Go Back'))
      ],
    ));
  }
}
