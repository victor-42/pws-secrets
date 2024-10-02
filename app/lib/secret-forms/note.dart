import 'dart:math';

import 'package:app/state-manager.dart';
import 'package:app/widgets/secret_setting_radiobutton.dart';
import 'package:flutter/material.dart';

const List<String> placeholderTexts = [
  "🔒 This note will self-destruct in 5 seconds...",
  "Type your secret here... I promise I won't tell 🤫",
  "Enter the recipe for your invisibility potion here...",
  "Shh... What's the password to the secret club?",
  "Jot down the location of the hidden treasure here...",
  "The meaning of life is... (your guess here)",
  "Write the secret handshake details here...",
  "Confess your love for pineapple pizza here...",
  "Secret superhero identity goes here...",
  "Whisper your most embarrassing moment here...",
  "Draft your plan for world domination here...",
  "Your alias for undercover missions...",
  "Type the secret code to unlock the mystery...",
  "Hide your secret recipe for the best cookies ever...",
  "Record the coordinates for your secret hideout...",
  "Where did you hide the last piece of cake?",
  "Secretly confess your guilty pleasures here...",
  "Archive your plans for the zombie apocalypse...",
  "Detail your secret handshake here...",
  "Enter the magic words to summon your pet dragon...",
  "This note contains the answer to everything... Maybe.",
  "Jot down your secret plan to avoid chores...",
  "Reveal your hidden talent for underwater basket weaving...",
  "What's your superhero power? Type it secretly here...",
  "Note to self: Remember where I hid the chocolate...",
  "Your secret wish list (Santa won't peek, promise)...",
  "Concoct your potion ingredients list here...",
  "Where have you hidden the remote control this time?",
  "Plan your sneaky surprise party strategy here...",
  "Your secret bunker's Wi-Fi password...",
  "Whisper your most magical moment here...",
  "Plot your secret escape route from meetings...",
  "Craft your codename for secret missions...",
  "Memorize the secret family pie recipe here...",
  "Store your ideas for time travel here...",
  "Scribble down your hidden aspiration to be a ninja...",
  "Document your undercover identity for spy missions...",
  "Hide your blueprint for the ultimate pillow fort...",
  "Where's the secret stash of good vibes? Share here...",
  "Draft your acceptance speech for 'Best Secret Keeper' award...",
  "Record the incantation for invisibility here...",
  "Your master plan for sneaking snacks into the cinema...",
  "Detail your secret method for staying awake in meetings...",
  "Whisper your dream of becoming a space pirate...",
  "Hide the secret to eternal youth here (just in case)...",
  "Plan your sneaky pet's next misadventure...",
  "Store the formula for turning homework into pizza...",
  "Safeguard the secret of how you beat the game level...",
  "Jot down the lyrics to your secret shower song...",
  "Archive the secret to a perfect cup of coffee...",
];

class NoteForm extends StatefulWidget {
  const NoteForm({Key? key, required this.onChanged, required this.onSaved}) : super(key: key);

  final Function(NoteSecret) onChanged;
  final Function() onSaved;

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  String _placeholderText =
  placeholderTexts[Random().nextInt(placeholderTexts.length)];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a secret';
            }
            if (value.length > 1750) {
              return 'Secret is too long (max 1750 characters)';
            }
            return null;
          },
          onFieldSubmitted: (value) {
            widget.onSaved();
          },
          onChanged: (value) {
            widget.onChanged(NoteSecret(note: value));
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: _placeholderText,
            hintStyle: TextStyle(
              fontFamily: 'ChivoDivo',
              color: Color(0xffB3B3B3).withOpacity(0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
          maxLines: 10,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
