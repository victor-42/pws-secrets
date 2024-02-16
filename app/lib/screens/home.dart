import 'dart:async';
import 'dart:html';

import 'package:app/state-manager.dart';
import 'package:app/widgets/secret_archive_listtile.dart';
import 'package:flutter/material.dart';

const rotationText =
    'The key-rotation allows you to rotate the key used by the server for encrypting your messages. '
    'It is only possible once every 72 hours, since unopened secrets still need to be encryptable. '
    'For obvious reasons, you cannot set a specific encryption key, but a seed function will come in the future.';

class LastSecretsScreen extends StatefulWidget {
  const LastSecretsScreen({Key? key}) : super(key: key);

  @override
  State<LastSecretsScreen> createState() => LastSecretsScreenState();
}

class LastSecretsScreenState extends State<LastSecretsScreen> {
  int _currentTimerTime = -10;
  Timer? _timer;
  bool _isRotating = false;
  final List<SecretArchive> _demoArchives = [
    SecretArchive(
        uuid: '612da264-6d63-4a74-859d-d9e082d9bd3a',
        type: 'n',
        expiration: DateTime.parse('2022-09-27T16:02:08.070557'),
        createdAt: DateTime.parse('2023-10-12T16:02:08.070557'),
        openedAt: null),
    SecretArchive(
        uuid: '121aa264-6d63-4a74-859d-d9e082d9bd3a',
        type: 'i',
        createdAt: DateTime.parse('2023-10-12T16:02:08.070557'),
        openedAt: DateTime.parse('2023-11-19T16:02:08.070557'),
        expiration: DateTime.parse('2023-11-12T16:02:08.070557')
    ),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTimerTime = _currentTimerTime + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        child: Column(
          children: [
            // Welcome Title
            SizedBox(height: 20),
            // Last Secrets
            Text(
              'Last Secrets',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            // Last Secrets List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _demoArchives.length,
                itemBuilder: (BuildContext context, int index) {
                  return SArchiveTile(secretArchive: _demoArchives[index]);
                },
              ),
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),
            // Key Rotation
            Text('Key Rotation',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 15),
            Text(rotationText, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
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
                              _isRotating = true;
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
    );
  }
}
