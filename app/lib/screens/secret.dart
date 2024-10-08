import 'package:app/state-manager.dart';
import 'package:app/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../locator.dart';
import '../secret-forms/image.dart';
import '../secret-forms/login.dart';
import '../secret-forms/note.dart';
import '../widgets/radio_card_button.dart';
import '../widgets/secret_setting_radiobutton.dart';

class SecretScreen extends StatefulWidget {
  const SecretScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SecretScreen> createState() => SecretScreenState();
}

class SecretScreenState extends State<SecretScreen> {
  NoteSecret? _noteSecret;
  PasswordSecret? _passwordSecret;
  ImageSecret? _imageSecret;

  int _mode = 0;
  bool _optionsExpanded = false;
  bool _loading = false;
  SecretPreferences _secretPreferences = SecretPreferences(
    expireIn: 24,
    showFor: 60,
    saveMeta: false,
  );
  String secretUrl = '';
  final StateManager _stateManager = locator<StateManager>();

  static const List<List<dynamic>> _settings_rememberIdOptions = [
    ['Off', false],
    ['On', true],
  ];
  static const List<List<dynamic>> _settings_showForOptions = [
    ['Off', null],
    ['30s', 30],
    ['5m', 300],
    ['10m', 600],
  ];

  static const List<List<dynamic>> _settings_expireInOptions = [
    ['1d', 24],
    ['2d', 48],
    ['4d', 96],
    ['7d', 168],
  ];

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void changeMode(int mode) {
    setState(() {
      _mode = mode;
    });
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

  void _onSubmit() {
    var obj;
    switch (_mode) {
      case 0:
        obj = _noteSecret;
        if (obj == null || obj.note.isEmpty) {
          return;
        }
      case 1:
        obj = _passwordSecret;
        if (obj == null || (obj.password.isEmpty && obj.username.isEmpty)) {
          return;
        }
      case 2:
        obj = _imageSecret;
        if (obj == null || obj.imageFileName.isEmpty) {
          return;
        }
    }
    if (obj == null) {
      return;
    }

    setState(() {
      _loading = true;
    });
    _stateManager
        .createSecret(
            _mode == 0
                ? 'n'
                : _mode == 1
                    ? 'p'
                    : 'i',
            obj,
            _secretPreferences)
        .then((url) {
      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An Error occurred while creating a secret.'),
          ),
        );
        setState(() {
          _loading = false;
        });
        return;
      } else {
        setState(() {
          secretUrl = url;
          _loading = false;
        });
        _stateManager.reloadHomeInformation();
      }
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
                  iconWidget: const Image(
                    image: AssetImage('assets/secret-icons/notepad.png'),
                    filterQuality: FilterQuality.high,
                  ),
                  active: _mode == 0,
                  onClicked: () {
                    setState(() {
                      _mode = 0;
                    });
                  },
                ),
                const SizedBox(width: 20),
                RadioCardButton(
                  title: 'Login',
                  iconWidget: const Image(
                    image: AssetImage('assets/secret-icons/lock.png'),
                    filterQuality: FilterQuality.high,
                  ),
                  active: _mode == 1,
                  onClicked: () {
                    setState(() {
                      _mode = 1;
                    });
                  },
                ),
                const SizedBox(width: 20),
                RadioCardButton(
                  title: 'Image',
                  iconWidget: const Image(
                    image: AssetImage('assets/secret-icons/camera.png'),
                    filterQuality: FilterQuality.high,
                  ),
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
              child: IndexedStack(
                index: _mode,
                children: [
                  SizedBox(
                    height: _mode == 0 ? null : 1,
                    child: NoteForm(
                      onChanged: (noteSecret) {
                        setState(() {
                          _noteSecret = noteSecret;
                        });
                      },
                      onSaved: () {
                        _onSubmit();
                      },
                    ),
                  ),
                  SizedBox(
                    height: _mode == 1 ? null : 1,
                    child: LoginForm(
                      onChanged: (passwordSecret) {
                        setState(() {
                          _passwordSecret = passwordSecret;
                        });
                      },
                      onSaved: () {
                        _onSubmit();
                      },
                    ),
                  ),
                  SizedBox(
                      height: _mode == 2 ? null : 1,
                      child: ImageForm(
                        onChanged: (imageSecret) {
                          setState(() {
                            _imageSecret = imageSecret;
                          });
                        },
                        onSaved: () {
                          _onSubmit();
                        },
                      )),
                ],
              ),
            ),
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
                                onPressed: _loading
                                    ? null
                                    : () {
                                        _onSubmit();
                                      },
                                child: _loading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            const CircularProgressIndicator())
                                    : const Text('Make the secret secret',
                                style: TextStyle(fontSize: 16),)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: width > 600 ? 1 : 2,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
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
                    SizedBox(
                      height: 20,
                    ),
                    AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      clipBehavior: Clip.hardEdge,
                      height: _optionsExpanded
                          ? (width > breakpointSmall ? 205 : 275)
                          : 0,
                      padding: const EdgeInsets.all(20),
                      margin:
                          _optionsExpanded ? EdgeInsets.only(bottom: 20) : null,
                      child: Column(
                        children: [
                          Builder(builder: (context) {
                            List<Widget> childs = [
                              Row(
                                children: [
                                  Icon(Icons.calendar_month),
                                  Text('     Secret expires in'),
                                ],
                              ),
                              Builder(builder: (context) {
                                List<Widget> childs = [];
                                for (var option in _settings_expireInOptions) {
                                  childs.add(SettingRadioButton(
                                      title: option[0],
                                      active: _secretPreferences.expireIn ==
                                          option[1],
                                      onClicked: () {
                                        setState(() {
                                          _secretPreferences.expireIn =
                                              option[1];
                                          _stateManager.saveSecretPreferences(
                                              _secretPreferences);
                                        });
                                      }));
                                  childs.add(SizedBox(width: 10));
                                }
                                return Row(children: childs);
                              })
                            ];
                            if (width > breakpointSmall) {
                              return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: childs);
                            } else {
                              return Column(children: childs);
                            }
                          }),
                          SizedBox(height: 20),
                          Builder(builder: (context) {
                            List<Widget> childs = [
                              Row(
                                children: [
                                  Icon(Icons.visibility),
                                  Text('     Show secret for'),
                                ],
                              ),
                              Builder(builder: (context) {
                                List<Widget> childs = [];
                                for (var option in _settings_showForOptions) {
                                  childs.add(SettingRadioButton(
                                      title: option[0],
                                      active: _secretPreferences.showFor ==
                                          option[1],
                                      onClicked: () {
                                        setState(() {
                                          _secretPreferences.showFor =
                                              option[1];
                                          _stateManager.saveSecretPreferences(
                                              _secretPreferences);
                                        });
                                      }));
                                  childs.add(SizedBox(width: 10));
                                }
                                return Row(children: childs);
                              })
                            ];
                            if (width > breakpointSmall) {
                              return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: childs);
                            } else {
                              return Column(children: childs);
                            }
                          }),
                          SizedBox(height: 20),
                          Builder(builder: (context) {
                            List<Widget> childs = [
                              Row(
                                children: [
                                  Icon(Icons.save),
                                  Text('     Meta-Information'),
                                ],
                              ),
                              Builder(builder: (context) {
                                List<Widget> childs = [];
                                childs.add(CupertinoSwitch(
                                    activeColor:
                                        Theme.of(context).colorScheme.primary,
                                    value: _secretPreferences.saveMeta,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _secretPreferences.saveMeta = value;
                                        _stateManager.saveSecretPreferences(
                                            _secretPreferences);
                                      });
                                    }));
                                childs.add(SizedBox(width: 10));
                                return Row(children: childs, mainAxisAlignment: MainAxisAlignment.start,);
                              })
                            ];
                            if (width > breakpointSmall) {
                              return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: childs);
                            } else {
                              return Column(children: childs);
                            }
                          }),
                        ],
                      ),
                    ),
                    TextField(
                      controller: TextEditingController(text: secretUrl),
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 50,
                          minHeight: 45,
                        ),
                        // Different colors on different light / dark themes
                        prefixIconColor: Theme.of(context).brightness == Brightness.light
                            ? Color(0xff252525).withOpacity(0.8)
                            : Color(0xffB3B3B3).withOpacity(0.5),
                        prefixIcon: InkWell(
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            Clipboard.setData(
                                new ClipboardData(text: secretUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                              ),
                            );
                          },
                          child: Icon(Icons.copy),
                        ),
                        border: OutlineInputBorder(),
                        hintText: 'https://pws-secrets.com/secret/Asdfjkl1234...',
                        hintStyle: TextStyle(
                          fontFamily: 'ChivoDivo',
                          // Different colors on different light / dark themes
                          color: Theme.of(context).brightness == Brightness.light
                              ? Color(0xff252525).withOpacity(0.8)
                              : Color(0xffB3B3B3).withOpacity(0.7),
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      readOnly: true,
                      selectionControls: MaterialTextSelectionControls(),
                      enableInteractiveSelection: true,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
