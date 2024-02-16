import 'package:app/state-manager.dart';
import 'package:flutter/material.dart';

class SArchiveTile extends StatelessWidget {
  final SecretArchive secretArchive;

  SArchiveTile({required this.secretArchive});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.surface,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Builder(builder: (context) {
                  if (this.secretArchive.openedAt == null) {
                    return Icon(Icons.visibility_off_outlined);
                  } else {
                    return Icon(Icons.visibility_outlined);
                  }
                }),
                SizedBox(width: 10),

                Builder(
                    builder: (context) {
                      switch (this.secretArchive.type) {
                        case 'n':
                          return Icon(Icons.note_outlined);
                        case 'l':
                          return Icon(Icons.key_outlined);
                        case 'i':
                          return Icon(Icons.image_outlined);
                        default:
                          return Icon(Icons.key_outlined);
                      }
                    }
                ),
                SizedBox(width: 10),
                Builder(builder: (context) {
                  var startOfId = this.secretArchive.uuid.substring(0, 4);
                  var endOfId = this.secretArchive.uuid.substring(this.secretArchive.uuid.length - 4);
                  return Text(startOfId + '...' + endOfId);
                }),
                SizedBox(width: 10,),
                Builder(
                    builder: (context) {
                      if (this.secretArchive.openedAt == null) {
                        return Text('Opened At +00:00');
                      } else {
                        return Text('Closed At +00:00');
                      }
                    }
                ),
              ],
            ),

            Builder(builder: (context) {
              Widget forgetButton = OutlinedButton(onPressed: () {}, child: Icon(Icons.delete_outline, size: 20,));
              Widget blockButton = OutlinedButton(onPressed: () {}, child: Icon(Icons.block,size: 20,));
              if (this.secretArchive.openedAt == null) {
                return Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                        child: blockButton),
                    SizedBox(width: 5,),
                    SizedBox(
                        height: 50,
                        width: 50,
                        child: forgetButton),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Container(
                        height: 50,
                        width: 50
                    ),                    SizedBox(width: 15,),

                    SizedBox(
                      height: 50,
                      width: 50,
                        child: forgetButton),

                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
