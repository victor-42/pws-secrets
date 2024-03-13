import 'dart:async';
import 'dart:html';

import 'package:app/state-manager.dart';
import 'package:app/widgets/radio_card_button.dart';
import 'package:app/widgets/secret_archive_listtile.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

const rotationText =
    'The key-rotation allows you to rotate the key used by the server for encrypting your messages. '
    'It is only possible once every 72 hours, since unopened secrets still need to be encryptable. '
    'For obvious reasons, you cannot set a specific encryption key, but a seed function will come in the future.';

const String oneTimeSecretText =
    'Share confidential data that is accessible only once. An ideal method for transmitting passwords, credit card details, private keys, access data, images or other sensitive information.';
const String encryptionText =
    'Your secret is encrypted into the url, which can only be shared by you. Without the full link, neither we nor anyone else can decrypt your secret.';
const String yourChoiceText =
    'The application offers you three ways to securely share your secret. Whether you want to securely send a personal note, login details or a picture as a secret, our platform has everything you need.';

class LastSecretsScreen extends StatefulWidget {
  final Function onToNewSecrets;

  const LastSecretsScreen({Key? key, required this.onToNewSecrets})
      : super(key: key);

  @override
  State<LastSecretsScreen> createState() => LastSecretsScreenState();
}

class LastSecretsScreenState extends State<LastSecretsScreen> {

  bool _isRotating = false;
  final StateManager _stateManager = locator<StateManager>();

  @override
  void dispose() {
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

            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('One-Time Secrets',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 15),
                Text(oneTimeSecretText, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 30),
                Text('End-to-End Encryption',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 15),
                Text(encryptionText, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 30),
                Text('Your Choice',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 15),
                Text(yourChoiceText, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    HomeSecretButtons(onClick: () {}, assetPath: 'icons/notepad.png'),
                    HomeSecretButtons(onClick: () {}, assetPath: 'icons/lock.png'),
                    HomeSecretButtons(onClick: () {}, assetPath: 'icons/camera.png'),
                  ],
                )
              ],
            ),
            SizedBox(height: 50),
            // Key Rotation
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
            // Print URL without path
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

          ],
        ),
      ),
    );
  }
}
