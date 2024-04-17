import 'package:app/state-manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        padding: const EdgeInsets.fromLTRB(25, 1, 25, 1),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(builder: (context) {
              switch (widget.secretArchive.type) {
                case 'n':
                  return Image.asset(
                    'icons/notepad.png',
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                    height: 25,
                  );
                case 'l':
                  return Image.asset(
                    'icons/lock.png',
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                    height: 25,
                  );
                case 'i':
                  return Image.asset(
                    'icons/camera.png',
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                    height: 25,
                  );
                default:
                  return Image.asset(
                    'icons/notepad.png',
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                    height: 25,
                  );
              }
            }),
            Text(
              'ID',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.5),
                  ),
            ),
            Builder(builder: (context) {
              var startOfId = widget.secretArchive.uuid.substring(0, 12);
              var endOfId = this
                  .widget
                  .secretArchive
                  .uuid
                  .substring(widget.secretArchive.uuid.length - 2);
              return Tooltip(
                  message: widget.secretArchive.uuid,
                  child: Text(startOfId + '...' + endOfId));
            }),
            Text(
              'created',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.5),
                  ),
            ),
            Builder(builder: (context) {
              return Text(DateFormat('dd.MM.yyyy')
                  .format(widget.secretArchive.createdAt));
            }),
            Text(
              'valid',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.5),
                  ),
            ),
            Builder(builder: (context) {
              if (widget.secretArchive.openedAt == null) {
                return Image.asset(
                  'icons/check-mark.png',
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                  height: 25,
                );
              }
              return Image.asset(
                'icons/cross-mark.png',
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
                height: 25,
              );
            }),
          ],
        ),
      ),
    );
  }
}
