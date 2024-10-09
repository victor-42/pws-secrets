import 'dart:async';

import 'package:app/state-manager.dart';
import 'package:app/widgets/accordion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../locator.dart';

class LinkedTextRowWidget extends StatefulWidget {
  final String headline;
  final String linkText;
  final bool usePrimaryColor;

  const LinkedTextRowWidget({Key? key,
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
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge,
          ),
        ),
        Expanded(
          flex: 8,
          child: InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onHover: (value) {
              setState(() {
                _isHovering = value;
              });
            },
            child: Text(widget.linkText,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(
                  color: _isHovering
                      ? Theme
                      .of(context)
                      .primaryColor
                      : widget.usePrimaryColor
                      ? Theme
                      .of(context)
                      .primaryColor
                      : Theme
                      .of(context)
                      .textTheme
                      .bodyLarge!
                      .color,
                  //decoration: TextDecoration.underline,
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
  const AboutScreen({Key? key}) : super(key: key);

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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                            'We take privacy very seriously, as the main purpose of the website is to preserve it. This policy describes the measures taken by pws_secrets to protect the privacy of its users.',
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge),
                        const SizedBox(height: 10),
                        Text(
                          '1. Description of the service',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'pws_secrets is a free web-based service that allows users to create encrypted messages that they can exchange over the Internet as unique HTTPS URLs '
                              '(hereinafter referred to as links), which by default expire after initial access through any web browser.\n\n'
                              'Since pws_secrets does not provide any means of transmitting the link, the responsibility for sending the link lies with the users of pws_secrets.\n\n'
                              'Depending on the communication channel you choose (e.g. e-mail, fax, SMS, telephone, instant messaging, social media) there may be a certain risk  '
                              'third parties may intercept your communication, gain knowledge of the link provided and thus be able to read your secrets. ',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '2. How the secrets and their contents are processed',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The link is generated in the user\'s browser and is never sent as such to pws_secrets. The link is therefore only in the hands of the sender (and later '
                              'possibly the recipient). Therefore there is no way to restore a secret if a user loses the link. \n\n'
                              'Since only the link binds the decryption key to the contents of the secret and pws_secrets does not own the link, at no time is a message in a readable '
                              'format held by pws_secrets. This ensures that nobody (not even the administrators of pws_secrets) can read a note.\n\n'
                              'Once a created URL has been retrieved, there is absolutely no way to restore it.\n\n'
                              'The pws_secrets system administrator team will do as much as possible to protect the website from unauthorized access, modification or destruction. But '
                              ' even if someone or something manages to gain access to the web server, they cannot read the secrets, because their content is encrypted and cannot be '
                              'decrypted without the links that pws_secrets never has.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '3. Collection and processing of personal data',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'For the purpose of visiting the website, we only collect and process the information and personal data that your internet browser automatically transmitted to us, such as\n\n'
                              '- date and time of the call of the web page\n'
                              '- your browser type and version and browser settings\n'
                              '- name and version of your operating system the website from which you visit our website (referrer URL)\n'
                              '- your IP address\n'
                              '- the URL you requested \n \n'
                              'This information and personal data is required for the purpose of delivering the content of the website correctly, as well as to ensure network and information '
                              'security and to protect the website from attacks, disruptions and damage. '
                              'The personal data collected when the website is accessed, in particular the user\'s IP address, is deleted no later than seven days after it was collected, '
                              'unless an attack or threat by the user has been identified.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '4. Pseudonymised data',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The creator of a secret can enter personal data into the message or send it via image. Even if these data are encrypted, they can be decrypted again and thus '
                              'represent pseudonymised (personal) data. In any case, the creator of the note cannot be deduced from the database of pws_secrets, because pws_secrets does not '
                              'store URLs that have been created.\n\n'
                              'The decryption of the message data is in the hands of the users (sender and recipient). pws_secrets is not able to decrypt the note and access the data (personal '
                              'or other) entered by the creator, because pws_secrets never has the decryption key, which is only contained in the link.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '5. Disclaimer',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'When a person clicks on a pws_secrets link, pws_secrets disclaims any responsibility for the content of the note.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '6. Disclosure of data to third parties',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'pws_secrets does not share, sell or use information with others in any way not mentioned in this privacy statement.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '7. Use of cookies',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'pws_secrets does not use cookies (small text files that are stored on your computer by your browser when you visit a website), not even in our own interest, '
                              ' to improve the use of our website and our service. However, we store information locally on your web browser, this is limited to the preferences used to create a secret and an identifier of the created secrets (however, this function is off by default).',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '8. Children',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The service is not aimed at children under 16 and is not intended to attract them. Minors must obtain the express consent of their parents or legal guardians'
                              ' before accessing or using pws_secrets.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '9. Validity of this privacy policy',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Please note that this privacy policy may be changed from time to time. We expect that most changes will be minor. However, we will post any changes to the policy '
                              'on this page, and if the changes are significant, we will post a more prominent notice, such as a notice on the home page. Each version of this Policy is identified '
                              'at the top of the page by its effective date.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '10. Contact',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'If you have any questions about this privacy policy or other privacy concerns, please email us at secrets@pws-agency.com '
                              ' and we will respond to you in less than 5 business days.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        )
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
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
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
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 6,
                              child: Card(
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
                                      const SizedBox(width: 20),
                                      Text(
                                        _currentTimerTime <= 0
                                            ? 'Rotation blocked for'
                                            : 'Not rotated since',
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                            color: Theme
                                                .of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color!
                                                .withOpacity(0.5),
                                            fontSize: 14),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${_currentTimerTime <= 0 ? '-' : '+'} '
                                            '${(_currentTimerTime.abs() ~/
                                            86400)
                                            .toString()
                                            .padLeft(2, '0')}d '
                                            '${(_currentTimerTime.abs() ~/
                                            3600 % 24)
                                            .toString()
                                            .padLeft(2, '0')}h '
                                            '${(_currentTimerTime.abs() ~/ 60 %
                                            60)
                                            .toString()
                                            .padLeft(2, '0')}m '
                                            '${(_currentTimerTime.abs() % 60)
                                            .toString()
                                            .padLeft(2, '0')}s',
                                        style:
                                        Theme
                                            .of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ),
                            Flexible(flex: 6,
                              child:
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
                                    : const Text('Rotate Key'),
                              ),

                            )
                            ,
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
                      'Version 2.0',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                        color: Theme
                            .of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.5),
                      ),
                    ),
                    Row(
                      children: [
                        Text('made with ',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(0.5),
                          ),),
                        Image.asset(
                          // If dark, use different image
                          Theme
                              .of(context)
                              .brightness == Brightness.dark
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
        )
        ,
      )
      ,
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
          style: Theme
              .of(context)
              .textTheme
              .bodyLarge,
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
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge!
                .copyWith(
              color: Theme
                  .of(context)
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
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  faqList[index][1],
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge,
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
