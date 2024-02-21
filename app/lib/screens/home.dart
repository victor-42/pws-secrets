import 'dart:async';
import 'dart:html';

import 'package:app/state-manager.dart';
import 'package:app/widgets/secret_archive_listtile.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

const rotationText =
    'The key-rotation allows you to rotate the key used by the server for encrypting your messages. '
    'It is only possible once every 72 hours, since unopened secrets still need to be encryptable. '
    'For obvious reasons, you cannot set a specific encryption key, but a seed function will come in the future.';

class LastSecretsScreen extends StatefulWidget {
  final Function onToNewSecrets;

  const LastSecretsScreen({Key? key, required this.onToNewSecrets})
      : super(key: key);

  @override
  State<LastSecretsScreen> createState() => LastSecretsScreenState();
}

class LastSecretsScreenState extends State<LastSecretsScreen> {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(builder: (context) {
                  if (_stateManager.oldArchives == null ||
                      _stateManager.oldArchives!.length == 0) {
                    return SizedBox(
                      width: 120,
                    );
                  }
                  return SizedBox(
                    width: 120,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          _stateManager.reloadHomeInformation();
                          setState(() {});
                        },
                        hoverColor: Colors.transparent,
                        icon: Icon(Icons.refresh),
                      ),
                    ),
                  );
                }),
                Text(
                  'Last Secrets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Builder(builder: (context) {
                  if (_stateManager.oldArchives == null ||
                      _stateManager.oldArchives!.length == 0) {
                    return SizedBox(
                      width: 120,
                    );
                  }
                  return SizedBox(
                    width: 120,
                    child: ElevatedButton(
                        onPressed: () {
                          _stateManager.clearOldArchives();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.background),
                        child: Text('Clear Closed')),
                  );
                })
              ],
            ),
            const SizedBox(height: 15),
            // Last Secrets List
            Builder(builder: (context) {
              if (_stateManager.oldArchives == null) {
                return SizedBox(
                    height: 50,
                    width: 50,
                    child: const CircularProgressIndicator());
              }
              if (_stateManager.oldArchives!.length == 0) {
                return Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text('You have yet to create your first Secret! (And safe the metadata)',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          widget.onToNewSecrets();
                        },
                        child: Text('Create Secret')),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                );
              }
              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _stateManager.oldArchives!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SArchiveTile(
                        secretArchive: _stateManager.oldArchives![index],
                      onBlock: (uuid) {
                        _stateManager.blockArchive(uuid);
                        setState(() {});
                      },
                    );
                  },
                ),
              );
            }),

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
    );
  }
}
