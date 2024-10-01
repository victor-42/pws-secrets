import 'dart:async';

import 'package:app/state-manager.dart';
import 'package:app/widgets/accordion.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../locator.dart';

class LinkedTextRowWidget extends StatefulWidget {
  final String headline;
  final String linkText;
  final bool usePrimaryColor;

  const LinkedTextRowWidget(
      {Key? key,
      required this.headline,
      required this.linkText,
      required this.usePrimaryColor})
      : super(key: key);

  @override
  State<LinkedTextRowWidget> createState() => LinkedTextRowWidgetState();
}

class LinkedTextRowWidgetState extends State<LinkedTextRowWidget> {
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            widget.headline,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Expanded(
          flex: 8,
          child: InkWell(
            hoverColor: Colors.transparent,
            onHover: (value) {
              setState(() {
                _isHovering = value;
              });
            },
            child: Text(widget.linkText,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: _isHovering
                      ? Theme.of(context).primaryColor
                      : widget.usePrimaryColor
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyLarge!.color,
                  decoration: TextDecoration.underline,
                )),
            onTap: () async {
              // Open link
              if (widget.linkText.contains('+49')) {
                await launchUrl(
                  Uri.parse('tel:${widget.linkText}'),
                );
                return;
              }
              if (widget.linkText.contains('@')) {
                await launchUrl(
                  Uri.parse('mailto:${widget.linkText}'),
                );
                return;
              }
              await launchUrl(
                widget.linkText.contains('https://')
                    ? Uri.parse(widget.linkText)
                    : Uri.parse('https://${widget.linkText}'),
              );
            },
          ),
        ),

      ],
    );
  }
}

class AboutScreen extends StatefulWidget {

  const AboutScreen({Key? key})
      : super(key: key);

  @override
  State<AboutScreen> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  int _currentTimerTime = 1;
  Timer? _timer;
  bool _isRotating = false;
  final StateManager _stateManager = locator<StateManager>();
  final List<GlobalKey<SecretsAccordionState>> _accordKeys = [
    GlobalKey<SecretsAccordionState>(),
    GlobalKey<SecretsAccordionState>(),
    GlobalKey<SecretsAccordionState>(),
    GlobalKey<SecretsAccordionState>(),
    GlobalKey<SecretsAccordionState>()
  ];

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
        -_stateManager.oldExpiration!.difference(DateTime.now()).inSeconds -
            (72 + 1) * 3600;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTimerTime = _currentTimerTime + 1;
      });
    });
  }

  setAccordionIndex(int index) {
    _accordKeys[index].currentState?.setExpanded(true);
    for (var i = 0; i < _accordKeys.length; i++) {
      if (i != index) {
        _accordKeys[i].currentState?.setExpanded(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 15),
                SecretsAccordion(
                  key: _accordKeys[0],
                  title: 'Imprint',
                  child: const ImprintAccordion(),
                ),
                const SizedBox(height: 15),
                SecretsAccordion(
                  key: _accordKeys[1],
                  title: 'FAQ',
                  child: const FaqAccordion(),
                ),
                const SizedBox(height: 15),
                SecretsAccordion(
                    key: _accordKeys[2],
                    title: 'Privacy Policy',
                    child: Column(
                      children: [
                        Text(
                          'We are committed to protecting your privacy. We will only use the information that we collect about you lawfully (in accordance with the Data Protection Act 1998 and the General Data Protection Regulation).',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    )),
                const SizedBox(height: 15),
                SecretsAccordion(
                    key: _accordKeys[3],
                    title: 'Open Source',
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'This project is open source and can be found on GitHub. Feel free to contribute to the project or use it for your own purposes.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        const LinkedTextRowWidget(
                          headline: 'GitHub: ',
                          linkText: 'https://github.com/victor-42/pws-secrets',
                          usePrimaryColor: false,
                        )
                      ],
                    )),
                const SizedBox(height: 15),
                SecretsAccordion(
                    title: 'Key Rotation',
                    key: _accordKeys[4],
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'The key-rotation allows you to rotate the key used by the server for encypting your messages. It is only possible once every 7 days, since unopened secrets still need to be encryptable.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/secret-icons/key.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _currentTimerTime <= 0
                                          ? 'Rotation blocked for'
                                          : 'Not rotated since',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color!
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${_currentTimerTime <= 0 ? '-' : '+'} '
                                      '${(_currentTimerTime.abs() ~/ 86400).toString().padLeft(2, '0')}d '
                                      '${(_currentTimerTime.abs() ~/ 3600 % 24).toString().padLeft(2, '0')}h '
                                      '${(_currentTimerTime.abs() ~/ 60 % 60).toString().padLeft(2, '0')}m '
                                      '${(_currentTimerTime.abs() % 60).toString().padLeft(2, '0')}s',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.refresh,
                                size: 18,
                              ),
                              onPressed: _currentTimerTime > 0 && !_isRotating
                                  ? () {
                                      setState(() {
                                        _isRotating = true;
                                      });
                                      _stateManager.rotateKey().then((value) {
                                        if (value) {
                                          _initState();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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
                              label: _isRotating
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator())
                                  : const Text('Request Rotation'),
                            ),
                          ],
                        )
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Version 1.9',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(0.5),
                          ),
                    ),
                    Row(
                      children: [
                        Text('made with ',
                            style: Theme.of(context).textTheme.bodyLarge),
                        Image.asset(
                          // If dark, use different image
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/secret-icons/heart-red.png'
                              : 'assets/secret-icons/heart.png',
                          height: 20,
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImprintAccordion extends StatelessWidget {
  const ImprintAccordion();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'pws_agency\nProf.-Messerschmitt-Str. 1a\n86159 Augsburg\nGermany\n\nRepresented by: Pascal Roth',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        const LinkedTextRowWidget(
            headline: 'Phone: ',
            linkText: '+49 821 58910720',
            usePrimaryColor: false),
        const LinkedTextRowWidget(
            headline: 'Mail: ',
            linkText: 'info@pws-agency.com',
            usePrimaryColor: false),
        const LinkedTextRowWidget(
          headline: 'Web: ',
          linkText: 'https://pws-agency.com',
          usePrimaryColor: false,
        ),
      ],
    );
  }
}

class FaqAccordion extends StatelessWidget {
  const FaqAccordion();

  final List<List<String>> faqList = const [
    [
      'Is pws_secret really privat?',
      'We are confident that pws_secrets is both private and secure, and we are constantly working to make it that way! For more details please read our privacy policy.'
    ],
    [
      'How can I send my note? Is there a way to send the link directly from the website?',
      'pws_secrets gives you a link to your note. You need to copy and paste this link into an email (or instant message) and send it to the person who should read the note.'
    ],
    [
      'What secrets can I send with pws_secrets?',
      'You have the possibility to send a secret note, access data or pictures via pws_secrets. Use the taps with the icons at the bottom of the page to choose one of the functions.'
    ],
    [
      'Can I send a secret to multiple recipients?',
      'No, currently a secret message can only be opened once and is only valid as long as specified by the creator.'
    ],
    [
      'What can I do if I regret sending the note or if I accidentally send it to someone I don\'t want to read?',
      'You just have to insert the link in the URL of your browser, when the secret is displayed, it will destroy itself. If the person you sent the linkt to tries to do the same, he will see the message that the secret is expired or invalid.'
    ],
    [
      'Is it possible to see a recently read note about the history of the browser, the back button, or the function of the recently closed tabs?',
      'A secret note destroys itself after reading -- there is no way to re-read it after reading it.'
    ],
    [
      'How much time are unread notes stored on the servers?',
      'Only secret images are stored encrypted on the server for a maximum of 7 days.'
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequently Asked Questions',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.5),
                )),
        SizedBox(height: 10),
        ListView.builder(
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  '${(index + 1).toString()}. ${faqList[index][0]}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  faqList[index][1],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            );
          },
          itemCount: faqList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}
