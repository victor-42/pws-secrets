import 'package:app/state-manager.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import '../secret-forms/image.dart';
import '../secret-forms/login.dart';
import '../secret-forms/note.dart';
import '../widgets/radio_card_button.dart';
import '../widgets/secret_setting_radiobutton.dart';

class SecretScreen extends StatefulWidget {
  const SecretScreen({Key? key}) : super(key: key);

  @override
  State<SecretScreen> createState() => SecretScreenState();
}

class SecretScreenState extends State<SecretScreen> {
  int _mode = 0;
  final List<Widget> _forms = [
    const NoteForm(),
    const LoginForm(),
    const ImageForm(),
  ];
  bool _optionsExpanded = false;
  SecretPreferences _secretPreferences = SecretPreferences(
    expireIn: 24,
    showFor: 60,
    saveMeta: false,
  );
  String secretUrl = 'https://pws-secrets.com/secret/1234567890';
  final StateManager _stateManager = locator<StateManager>();

  static const List<List<dynamic>> _settings_rememberIdOptions = [
    ['Off', false],
    ['On', true],
  ];
  static const List<List<dynamic>>_settings_showForOptions = [
    ['Off', null],
    ['30s', 30],
    ['1m', 60],
    ['5m', 300],
  ];

  static const List<List<dynamic>> _settings_expireInOptions = [
    ['1h', 1],
    ['12h', 12],
    ['24h', 24],
    ['48h', 48],
    ['72h', 72],
  ];

  @override
  void initState() {
    super.initState();
    _initState();
  }

  onDispose() {
    _stateManager.saveSecretPreferences(_secretPreferences);
  }

  Future<void> _initState() async {
    await _stateManager.initPrefs();
    setState(() {
      _secretPreferences = _stateManager.getSecretPreferences();
    });
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            // Radio Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RadioCardButton(
                  title: 'Note',
                  iconWidget: const Icon(Icons.note),
                  active: _mode == 0,
                  onClicked: () {
                    setState(() {
                      _mode = 0;
                    });
                  },
                ),
                RadioCardButton(
                  title: 'Login',
                  iconWidget: const Icon(Icons.lock),
                  active: _mode == 1,
                  onClicked: () {
                    setState(() {
                      _mode = 1;
                    });
                  },
                ),
                RadioCardButton(
                  title: 'Image',
                  iconWidget: const Icon(Icons.image),
                  active: _mode == 2,
                  onClicked: () {
                    setState(() {
                      _mode = 2;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 24),
            // Form
            Container(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
                child: _forms[_mode]),
            Container(
              constraints: BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Note saved'),
                                ),
                              );
                            },
                            child: const Text('Make the secret secret'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: width > 600 ? 1 : 2,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _optionsExpanded = !_optionsExpanded;
                              });
                            },
                            child: const Icon(Icons.settings),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  AnimatedContainer(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(),
                    ),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    clipBehavior: Clip.hardEdge,
                    height: _optionsExpanded ? (width > breakpointSmall ? 205 : 275) : 0,
                    padding: const EdgeInsets.all(20),
                    margin: _optionsExpanded ? EdgeInsets.only(bottom: 20): null,
                    child:
                    Column(
                      children: [
                        Builder(
                          builder: (context) {
                            List<Widget> childs = [
                              Row(
                                children: [
                                  Icon(Icons.timer),
                                  Text(' Epires in:'),
                                ],
                              ),
                              Builder(
                                  builder: (context) {
                                    List<Widget> childs = [];
                                    for (var option in _settings_expireInOptions) {
                                      childs.add(
                                          SettingRadioButton(title: option[0], active: _secretPreferences.expireIn == option[1], onClicked: () {
                                            setState(() {
                                              _secretPreferences.expireIn = option[1];
                                              _stateManager.saveSecretPreferences(_secretPreferences);

                                            });
                                          })
                                      );
                                      childs.add(SizedBox(width: 10));
                                    }
                                    return Row(
                                        children: childs
                                    );
                                  }
                              )
                            ];
                            if (width > breakpointSmall) {
                              return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: childs
                              );
                            } else {
                              return Column(
                                  children: childs
                              );
                            }
                          }
                        ),
                        SizedBox(height: 20),
                        Builder(
                            builder: (context) {
                              List<Widget> childs = [
                                Row(
                                  children: [
                                    Icon(Icons.visibility_outlined),
                                    Text(' Show secret for:'),
                                  ],
                                ),
                                Builder(
                                    builder: (context) {
                                      List<Widget> childs = [];
                                      for (var option in _settings_showForOptions) {
                                        childs.add(
                                            SettingRadioButton(title: option[0], active: _secretPreferences.showFor == option[1], onClicked: () {
                                              setState(() {
                                                _secretPreferences.showFor = option[1];
                                                _stateManager.saveSecretPreferences(_secretPreferences);
                                              });
                                            })
                                        );
                                        childs.add(SizedBox(width: 10));
                                      }
                                      return Row(
                                          children: childs
                                      );
                                    }
                                )
                              ];
                              if (width > breakpointSmall) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: childs
                                );
                              } else {
                                return Column(
                                    children: childs
                                );
                              }
                            }
                        ),
                        SizedBox(height: 20),
                        Builder(
                            builder: (context) {
                              List<Widget> childs = [
                                Row(
                                  children: [
                                    Icon(Icons.save_outlined),
                                    Text(' Remember Meta-Information:'),
                                  ],
                                ),
                                Builder(
                                    builder: (context) {
                                      List<Widget> childs = [];
                                      for (var option in _settings_rememberIdOptions) {
                                        childs.add(
                                            SettingRadioButton(title: option[0], active: _secretPreferences.saveMeta == option[1], onClicked: () {
                                              setState(() {
                                                _secretPreferences.saveMeta = option[1];
                                                _stateManager.saveSecretPreferences(_secretPreferences);
                                              });
                                            })
                                        );
                                        childs.add(SizedBox(width: 10));
                                      }
                                      return Row(
                                          children: childs
                                      );
                                    }
                                )
                              ];
                              if (width > breakpointSmall) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: childs
                                );
                              } else {
                                return Column(
                                    children: childs
                                );
                              }
                            }
                        ),
                      ],

                    ),
                  ),
                  TextField(
                    controller: TextEditingController(text: secretUrl),
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                            ),
                          );
                        },
                        child: Icon(Icons.copy),
                      ),
                      border: OutlineInputBorder(),
                      hintText: secretUrl,
                    ),
                    readOnly: true,
                    selectionControls: MaterialTextSelectionControls(),
                    enableInteractiveSelection: true,
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
