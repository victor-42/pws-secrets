import 'dart:async';

import 'package:app/state-manager.dart';
import 'package:app/theme.dart';
import 'package:app/widgets/radio_card_button.dart';
import 'package:app/widgets/secret_archive_listtile.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
const String lastSecretText =
    'By enabling the \'Meta-Information\' option when creating a URL, you can save the additional details associated with your secret. Once activated, these meta-information will be displayed here.';

const List<dynamic> links = [
  ['Imprint', 0],
  ['FAQ Page', 1],
  ['Key Rotation', 4],
  ['Privacy Policy', 2],
];

class LastSecretsScreen extends StatefulWidget {
  final Function onToNewSecrets;
  final Function onToAbout;

  const LastSecretsScreen({Key? key, required this.onToNewSecrets, required this.onToAbout})
      : super(key: key);

  @override
  State<LastSecretsScreen> createState() => LastSecretsScreenState();
}

class LastSecretsScreenState extends State<LastSecretsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            PinnedMessage(),
            WelcomeTexts(onToNewSecrets: widget.onToNewSecrets),
            LastSecretsWidget(onToNewSecrets: widget.onToNewSecrets,onToAbout: widget.onToAbout,),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\u00a92024', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w100, color: Colors.grey.withOpacity(0.5))),
                InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Uri uri = Uri.https('pws-agency.com');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: Text(' pws_agency', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w100, color: Colors.grey.withOpacity(0.5)))),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class WelcomeTexts extends StatelessWidget {
  final Function onToNewSecrets;

  const WelcomeTexts({Key? key, required this.onToNewSecrets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 600),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 50),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('One-Time Secrets',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700)),
          const SizedBox(height: 15),
          Text(     oneTimeSecretText,
              style: Theme.of(context).textTheme.bodyMedium!,),
          const SizedBox(height: 50),
          Text('End-to-End Encryption',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700)),
          const SizedBox(height: 15),
          Text(encryptionText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 50),
          Text('Your Choice', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700)),
          const SizedBox(height: 15),
          Text(yourChoiceText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 50),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            HomeSecretButtons(
                onClick: () {
                  onToNewSecrets(0);
                },
                assetPath: 'assets/secret-icons/notepad.png'),
            HomeSecretButtons(
                onClick: () {
                  onToNewSecrets(1);
                },
                assetPath: 'assets/secret-icons/lock.png'),
            HomeSecretButtons(
                onClick: () {
                  onToNewSecrets(2);
                },
                assetPath: 'assets/secret-icons/camera.png'),
          ]),
          const SizedBox(height: 30),
        ]),
      ]),
    );
  }
}

class PinnedMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _mobile = MediaQuery.of(context).size.width < breakpointSmall;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 700),
      child: Card(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
                top: -20,
                left: 15,
                child: Transform.rotate(
                    angle: -0.3,
                    child: Image.asset(
                      'assets/secret-icons/pin.png',
                      height: 40,
                      width: 40,
                    ))),
            Positioned(
                top: -20,
                right: 15,
                child: Transform.rotate(
                    angle: 0.3,
                    child: Image.asset(
                      'assets/secret-icons/pin.png',
                      height: 40,
                      width: 40,
                    ))),
            Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Share a secret ',
                        style: TextStyle(
                            fontSize: _mobile ? 27 :  40,
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(
                        'assets/secret-icons/chain.png',
                        filterQuality: FilterQuality.high,
                        isAntiAlias: false,
                        height: 35,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontSize: 23,
                            fontFamily: 'SpaceGrotesk',
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                            fontWeight: FontWeight.w500
                        ),
                        children: [
                          TextSpan(
                            text: '...share sensitive information securely with a one-time link that ',
                          ),
                          TextSpan(
                              text: 'self-destructs',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          TextSpan(
                            text: ' after being accessed, ensuring your data stays private.',
                          ),
                        ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class LastSecretsWidget extends StatefulWidget {
  final Function onToNewSecrets;
  final Function onToAbout;

  const LastSecretsWidget({Key? key, required this.onToNewSecrets, required this.onToAbout})
      : super(key: key);

  @override
  State<LastSecretsWidget> createState() => LastSecretsWidgetState();
}

class LastSecretsWidgetState extends State<LastSecretsWidget> {
  bool _isRotating = false;
  final StateManager _stateManager = locator<StateManager>();
  List<bool> _linkHovering = [false, false, false, false];

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
    setState(() {
    });
    // Current Timer time as diff between now and oldExpiration in seconds
  }

  @override
  Widget build(BuildContext context) {
    bool _mobile = MediaQuery.of(context).size.width < breakpointSmall;
    return Column(
      children: [
        SizedBox(height: 40),
        Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Secrets',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700)),
              const SizedBox(height: 15),
              Text(lastSecretText,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        const SizedBox(height: 30),
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
            return Card(
                child: Container(
              constraints: BoxConstraints(maxWidth: 700, minWidth: 500),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                children: [
                  Image.asset(
                    'assets/secret-icons/no-entry.png',
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                    height: 25,
                  ),
                  SizedBox(
                    width: _mobile?20:100,
                  ),
                  Text(
                      'no one has saved the meta information ${_mobile ? '\n' : ''} yet, please reload',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(0.5),
                          )),
                ],
              ),
            ));
          }
          return Container(
            constraints: BoxConstraints(maxWidth: 700),
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
        const SizedBox(height: 30),
        ElevatedButton.icon(
            icon: Icon(
              Icons.refresh,
              size: 18,
            ),
            onPressed: () {
              _stateManager.reloadHomeInformation();
              setState(() {});
            },
            label: Text('Reload',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),)),

        const SizedBox(height: 40),
        Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text('Links',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700)),
        ),),
        const SizedBox(height: 15),
        Container(
          constraints: BoxConstraints(maxWidth: 600),
          height: 100,
          child: ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onHover: (value) {
                    setState(() {
                      _linkHovering[index] = value;
                    });
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    widget.onToAbout(links[index][1]);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.55,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(links[index][0],
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                //    decoration: TextDecoration.underline,
                                color: _linkHovering[index] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color,
                                  )),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
