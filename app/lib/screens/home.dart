import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';

const rotationText =
    'The key-rotation allows you to rotate the key used by the server for encrypting your messages. \n'
    'It is only possible once every 72 hours, since unopened secrets still need to be encryptable. \n'
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
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Welcome Title
            Text(
              'Welcome to pws_secrets',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            // Last Secrets
            Text(
              'Last Secrets',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            // Last Secrets List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Secret $index'),
                    subtitle: Text('Description of Secret $index'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to Secret Screen
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // Key Rotation
            Text('Key Rotation',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(rotationText, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
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
