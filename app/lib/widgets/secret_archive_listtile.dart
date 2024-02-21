import 'package:app/state-manager.dart';
import 'package:flutter/material.dart';

class SArchiveTile extends StatefulWidget {
  final SecretArchive secretArchive;
  final Function(String) onBlock;

  SArchiveTile({required this.secretArchive, required this.onBlock});

  @override
  State<SArchiveTile> createState() => SArchiveTileState();
}

class SArchiveTileState extends State<SArchiveTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.background,
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
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
                  if (widget.secretArchive.openedAt == null) {
                    return Icon(Icons.visibility_off_outlined);
                  } else {
                    return Icon(Icons.visibility_outlined);
                  }
                }),
                SizedBox(width: 10),
                Builder(builder: (context) {
                  switch (widget.secretArchive.type) {
                    case 'n':
                      return Icon(Icons.note_outlined);
                    case 'l':
                      return Icon(Icons.key_outlined);
                    case 'i':
                      return Icon(Icons.image_outlined);
                    default:
                      return Icon(Icons.key_outlined);
                  }
                }),
                SizedBox(width: 10),
                Builder(builder: (context) {
                  var startOfId = widget.secretArchive.uuid.substring(0, 4);
                  var endOfId = this
                      .widget.secretArchive
                      .uuid
                      .substring(widget.secretArchive.uuid.length - 4);
                  return Tooltip(
                      message: widget.secretArchive.uuid,
                      child: Text(startOfId + '...' + endOfId));
                }),
                SizedBox(
                  width: 10,
                ),
                Builder(builder: (context) {
                  if (widget.secretArchive.openedAt == null) {
                    int days = DateTime.now()
                        .difference(widget.secretArchive.createdAt)
                        .inDays;
                    int hours = DateTime.now()
                            .difference(widget.secretArchive.createdAt)
                            .inHours %
                        24;
                    return Tooltip(
                        message: 'Created At: ${widget.secretArchive.createdAt}',
                        child: Text(
                            'Created At +${days.toString().padLeft(2, '0')}D ${hours.toString().padLeft(2, '0')}H'));
                  } else {
                    int days = DateTime.now()
                        .difference(widget.secretArchive.openedAt!)
                        .inDays;
                    int hours = DateTime.now()
                            .difference(widget.secretArchive.openedAt!)
                            .inHours %
                        24;
                    return Tooltip(
                        message: 'Opened At: ${widget.secretArchive.openedAt}',
                        child: Text(
                            'Opened At +${days.toString().padLeft(2, '0')}D ${hours.toString().padLeft(2, '0')}H'));
                  }
                }),
              ],
            ),
            Builder(
              builder: (context) {
                if (widget.secretArchive.openedAt != null) {
                  return SizedBox(width: 50, height: 50);
                }
                return SizedBox(
                    height: 50,
                    width: 50,
                    child: OutlinedButton(
                        onPressed: () {
                            widget.onBlock(widget.secretArchive.uuid);
                        },
                        child: Icon(
                          Icons.block,
                          size: 20,
                        )));
              }
            ),
          ],
        ),
      ),
    );
  }
}
